require "test_helper"

# What moduler records in the audit log (see Moduler::Audit).
class AuditEventsTest < ActionDispatch::IntegrationTest
  setup do
    @member = moduler_users(:default)
    @administrator = moduler_users(:administrator)
  end

  # Signing in and out

  test "signing in records the session with the IP address and the request" do
    sign_in_as @member

    event = last_event("session.signed_in")
    assert_equal @member, event.user
    assert_equal @member.sessions.order(:created_at).last, event.subject
    assert_equal "127.0.0.1", event.ip_address
    assert event.request_id.present?
  end

  test "a wrong password records a failed sign in of the account" do
    sign_in_as @member, password: "wrong"

    event = last_event("session.sign_in_failed")
    assert_nil event.user
    assert_equal @member, event.subject
    assert_equal({ "reason" => "invalid_credentials" }, event.metadata)
  end

  test "an unknown email address records a failed sign in without an account" do
    post "/application/session", params: { user: { email_address: "nobody@domain.tld", password: "password123" } }

    event = last_event("session.sign_in_failed")
    assert_nil event.subject
  end

  test "an inactive account records a failed sign in" do
    @member.update!(status: :inactive)

    sign_in_as @member

    assert_equal({ "reason" => "inactive_account" }, last_event("session.sign_in_failed").metadata)
  end

  test "signing out records the session" do
    sign_in_as @member
    delete "/application/session"

    event = last_event("session.signed_out")
    assert_equal @member, event.user
    assert_equal last_event("session.signed_in").subject, event.subject
  end

  test "signing up records the new user" do
    post "/application/user", params: { user: { email_address: "new@domain.tld", password: "password123", password_confirmation: "password123" } }

    user = Moduler::User.find_by!(email_address: "new@domain.tld")
    event = last_event("user.signed_up")
    assert_equal user, event.user
    assert_equal user, event.subject
  end

  # Profile

  test "updating the profile records the changes" do
    sign_in_as @member
    patch "/application/profile", params: { user: { name: "Jane" } }

    event = last_event("user.updated")
    assert_equal @member, event.subject
    assert_equal [ nil, "Jane" ], event.metadata.dig("changes", "name")
    assert_equal false, event.metadata["password_changed"]
  end

  test "changing the password records it without the password digest" do
    sign_in_as @member
    patch "/application/profile", params: { user: { password_challenge: "password123", password: "newpassword123", password_confirmation: "newpassword123" } }

    event = last_event("user.updated")
    assert_equal true, event.metadata["password_changed"]
    assert_not event.metadata.fetch("changes", {}).key?("password_digest")
  end

  test "revoking a session in the profile records it" do
    session = moduler_sessions(:active)
    sign_in_as @member
    delete "/application/profile/sessions/#{session.id}"

    assert_equal session, last_event("session.revoked").subject
  end

  test "revoking all sessions in the profile records how many" do
    sign_in_as @member
    delete "/application/profile/sessions/revocation"

    event = last_event("user.sessions_revoked")
    assert_equal @member, event.subject
    assert_equal 2, event.metadata["count"]
  end

  # Documents

  test "accepting documents records them" do
    document = moduler_documents(:privacy_policy)
    document.file.attach(io: file_fixture("document.pdf").open, filename: "privacy-policy.pdf", content_type: "application/pdf")
    Moduler::UserDocument.where(user: @member).delete_all
    sign_in_as @member

    post "/application/document_acceptance", params: { document_acceptance: { document_ids: Moduler::Document.ids } }

    event = last_event("documents.accepted")
    assert_equal @member, event.subject
    assert_includes event.metadata["document_ids"], document.id
  end

  # Administration

  test "an administrator revoking a session records it" do
    session = moduler_sessions(:active)
    sign_in_as @administrator
    delete "/application/administration/sessions/#{session.id}"

    event = last_event("session.revoked")
    assert_equal @administrator, event.user
    assert_equal session, event.subject
  end

  test "creating and updating a user records the changes" do
    sign_in_as @administrator
    post "/application/administration/users", params: { user: { email_address: "new@domain.tld", name: "New", role: "member", status: "active", password: "password123" } }
    user = Moduler::User.find_by!(email_address: "new@domain.tld")
    patch "/application/administration/users/#{user.id}", params: { user: { role: "administrator" } }

    assert_equal user, last_event("user.created").subject
    assert_equal [ "member", "administrator" ], last_event("user.updated").metadata.dig("changes", "role")
  end

  test "creating and updating an organization records it as the organization of the event" do
    sign_in_as @administrator
    post "/application/administration/organizations", params: { organization: { name: "Initech" } }
    organization = Moduler::Organization.find_by!(name: "Initech")
    patch "/application/administration/organizations/#{organization.id}", params: { organization: { name: "Initrode" } }

    assert_equal organization, last_event("organization.created").organization
    assert_equal [ "Initech", "Initrode" ], last_event("organization.updated").metadata.dig("changes", "name")
  end

  test "creating and updating a role records it in its organization" do
    organization = moduler_organizations(:acme)
    sign_in_as @administrator
    post "/application/administration/roles", params: { role: { moduler_organization_id: organization.id, name: "Auditor", permissions: [ "tasks.read" ] } }
    role = organization.roles.find_by!(name: "Auditor")
    patch "/application/administration/roles/#{role.id}", params: { role: { name: "Auditor", permissions: [ "tasks.read", "tasks.write" ] } }

    assert_equal organization, last_event("role.created").organization
    assert_equal [ [ "tasks.read" ], [ "tasks.read", "tasks.write" ] ], last_event("role.updated").metadata.dig("changes", "permissions")
  end

  test "adding, changing and removing a member records it in the organization" do
    organization = moduler_organizations(:globex)
    sign_in_as @administrator
    post "/application/administration/memberships", params: { membership: { moduler_organization_id: organization.id, moduler_user_id: @member.id, moduler_role_id: moduler_roles(:globex_owner).id } }
    membership = organization.memberships.find_by!(user: @member)
    delete "/application/administration/memberships/#{membership.id}"

    assert_equal organization, last_event("membership.created").organization
    removed = last_event("membership.destroyed")
    assert_equal organization, removed.organization
    assert_equal membership.id, removed.subject_id
    assert_equal({ "user_id" => @member.id, "role_id" => moduler_roles(:globex_owner).id }, removed.metadata)
  end

  private

  def last_event(action)
    Moduler::AuditEvent.where(action:).order(:created_at).last || flunk("No #{action} event recorded")
  end
end
