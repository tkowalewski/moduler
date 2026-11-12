require "test_helper"

module Moduler
  # Uses the dummy application's ProjectsController, which requires tasks.write.
  class OrganizationScopedTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
      @acme = moduler_organizations(:acme)
    end

    test "sets the membership of the signed-in user for can?" do
      sign_in_as @user

      get "/application/organizations/#{@acme.id}/projects"

      assert_response :success
      assert_select "h1", text: "Projects"
    end

    test "can? is false for a permission the role does not grant" do
      @user.memberships.find_by!(organization: @acme).update!(role: moduler_roles(:acme_viewer))
      sign_in_as @user

      get "/application/organizations/#{@acme.id}/projects"

      assert_redirected_to "/application/"
    end

    test "uses the membership in the organization from the URL" do
      globex = moduler_organizations(:globex)
      @user.memberships.find_by!(organization: @acme).update!(role: moduler_roles(:acme_viewer))
      Moduler::Membership.create!(user: @user, organization: globex, role: moduler_roles(:globex_owner))
      sign_in_as @user

      get "/application/organizations/#{globex.id}/projects"
      assert_response :success

      get "/application/organizations/#{@acme.id}/projects"
      assert_redirected_to "/application/"
    end

    test "redirects for an organization id that is not a UUID" do
      sign_in_as @user

      get "/application/organizations/not-a-uuid/reports"

      assert_redirected_to "/application/"
    end
  end
end
