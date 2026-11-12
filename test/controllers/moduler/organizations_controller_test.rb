require "test_helper"

module Moduler
  class OrganizationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
      @acme = moduler_organizations(:acme)
      @globex = moduler_organizations(:globex)
    end

    test "show redirects to the login page when not authenticated" do
      get "/application/organizations/#{@acme.id}"

      assert_redirected_to "/application/session/new"
    end

    test "show redirects to the first sidebar resource the user's role grants" do
      sign_in_as @user

      get "/application/organizations/#{@acme.id}"

      assert_redirected_to "/application/organizations/#{@acme.id}/reports"
    end

    test "show skips sidebar resources whose permission the user's role does not grant" do
      @user.memberships.find_by!(organization: @acme).update!(role: moduler_roles(:acme_viewer))
      sign_in_as @user

      with_configuration(permissions: %w[ tasks.read tasks.write ], resources: [ { name: "projects", permission: "tasks.write" }, "reports" ]) do
        get "/application/organizations/#{@acme.id}"
      end

      assert_redirected_to "/application/organizations/#{@acme.id}/reports"
    end

    test "show uses the role in the organization from the URL" do
      @user.memberships.find_by!(organization: @acme).update!(role: moduler_roles(:acme_viewer))
      Moduler::Membership.create!(user: @user, organization: @globex, role: moduler_roles(:globex_owner))
      sign_in_as @user

      with_configuration(permissions: %w[ tasks.read tasks.write ], resources: [ { name: "projects", permission: "tasks.write" }, "reports" ]) do
        get "/application/organizations/#{@globex.id}"
        assert_redirected_to "/application/organizations/#{@globex.id}/projects"

        get "/application/organizations/#{@acme.id}"
        assert_redirected_to "/application/organizations/#{@acme.id}/reports"
      end
    end

    test "show redirects to the home page when the user's role grants no sidebar resource" do
      @user.memberships.find_by!(organization: @acme).update!(role: moduler_roles(:acme_viewer))
      sign_in_as @user

      with_configuration(permissions: %w[ tasks.write ], resources: [ { name: "projects", permission: "tasks.write" } ]) do
        get "/application/organizations/#{@acme.id}"
      end

      assert_redirected_to "/application/"
      assert_equal "You don't have access to any page in this organization.", flash[:alert]
    end

    test "organization pages show the switcher and no dashboard link in the sidebar" do
      Moduler::Membership.create!(user: @user, organization: @globex, role: moduler_roles(:globex_owner))
      sign_in_as @user

      get "/application/organizations/#{@globex.id}/reports"

      assert_response :success
      assert_select "aside details[data-controller=dropdown] summary", text: /Globex/
      assert_select "#organization_switcher li", count: 2
      assert_select "#organization_switcher [aria-current=true]", text: "Globex"
      assert_select "#organization_switcher a[href='/application/organizations/#{@acme.id}']", text: "Acme"
      assert_select "aside nav a[href='/application/organizations/#{@globex.id}']", count: 0
      assert_select "aside nav a", text: "Dashboard", count: 0
    end

    test "organization pages link the sidebar resources the user's role grants" do
      sign_in_as @user

      get "/application/organizations/#{@acme.id}/reports"

      assert_select "aside nav a[href$='/application/organizations/#{@acme.id}/reports']", text: "Reports"
      assert_select "aside nav a[href$='/application/organizations/#{@acme.id}/projects']", text: "Projects"
    end

    test "organization pages hide sidebar resources whose permission the user's role does not grant" do
      @user.memberships.find_by!(organization: @acme).update!(role: moduler_roles(:acme_viewer))
      sign_in_as @user

      get "/application/organizations/#{@acme.id}/reports"

      assert_select "aside nav a[href$='/application/organizations/#{@acme.id}/reports']", text: "Reports"
      assert_select "aside nav a[href$='/application/organizations/#{@acme.id}/projects']", count: 0
    end

    test "show redirects to the home page for an organization the user is not a member of" do
      sign_in_as @user

      get "/application/organizations/#{@globex.id}"

      assert_redirected_to "/application/"
      assert_equal "You don't have access to this organization.", flash[:alert]
    end

    test "show redirects to the home page after the user was removed from the organization" do
      sign_in_as @user
      get "/application/organizations/#{@acme.id}"
      assert_redirected_to "/application/organizations/#{@acme.id}/reports"

      @user.memberships.find_by!(organization: @acme).destroy!
      get "/application/organizations/#{@acme.id}"

      assert_redirected_to "/application/"
      follow_redirect!
      assert_select "#organizations", count: 0
    end

    test "show redirects to the home page for an organization that does not exist" do
      sign_in_as @user

      get "/application/organizations/00000000-0000-0000-0000-000000000000"

      assert_redirected_to "/application/"
    end

    test "show redirects administrators to the administration area" do
      sign_in_as moduler_users(:administrator)

      get "/application/organizations/#{@acme.id}"

      assert_redirected_to "/application/administration"
    end

    private

    # Runs the block with config/moduler.yml replaced by the given settings.
    def with_configuration(**settings)
      original = Moduler.configuration
      configuration = Moduler::Configuration.allocate
      configuration.instance_variable_set(:@configuration, settings)
      Moduler.instance_variable_set(:@configuration, configuration)
      yield
    ensure
      Moduler.instance_variable_set(:@configuration, original)
    end
  end
end
