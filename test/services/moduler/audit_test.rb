require "test_helper"

module Moduler
  class AuditTest < ActiveSupport::TestCase
    setup do
      @user = moduler_users(:administrator)
      @role = moduler_roles(:acme_viewer)
    end

    test "records the user, the organization and the request from Current" do
      Current.set(session: moduler_sessions(:active), organization: moduler_organizations(:globex), ip_address: "10.0.0.2", request_id: "abc") do
        event = Audit.record("report.exported", @role, format: "csv")

        assert_equal "report.exported", event.action
        assert_equal @role, event.subject
        assert_equal moduler_users(:default), event.user
        assert_equal moduler_organizations(:globex), event.organization
        assert_equal "10.0.0.2", event.ip_address
        assert_equal "abc", event.request_id
        assert_equal({ "format" => "csv" }, event.metadata)
      end
    end

    test "takes the organization of the subject outside an organization" do
      assert_equal moduler_organizations(:acme), Audit.record("role.updated", @role).organization
    end

    test "takes an organization as the subject's organization" do
      organization = moduler_organizations(:globex)

      assert_equal organization, Audit.record("organization.updated", organization).organization
    end

    test "records no organization for a subject without one" do
      assert_nil Audit.record("session.signed_in", moduler_sessions(:active)).organization
    end

    test "records the user and the organization given" do
      event = Audit.record("user.signed_up", @user, user: @user, organization: moduler_organizations(:globex))

      assert_equal @user, event.user
      assert_equal moduler_organizations(:globex), event.organization
    end

    test "records changes without timestamps and password digests" do
      changes = { "name" => [ "Old", "New" ], "updated_at" => [ 1.day.ago, Time.current ], "password_digest" => [ "a", "b" ] }

      event = Audit.record("user.updated", @user, changes:)

      assert_equal({ "changes" => { "name" => [ "Old", "New" ] } }, event.metadata)
    end

    test "records no changes when there are none" do
      assert_equal({}, Audit.record("user.updated", @user, changes: {}).metadata)
    end
  end
end
