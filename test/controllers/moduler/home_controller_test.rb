require "test_helper"

module Moduler
  class HomeControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
    end

    test "index redirects to the login page when not authenticated" do
      get "/application"

      assert_redirected_to "/application/session/new"
    end

    test "index welcomes the user and lists their organizations by name without the sidebar" do
      globex = moduler_organizations(:globex)
      Moduler::Membership.create!(user: @user, organization: globex, role: moduler_roles(:globex_owner))
      sign_in_as @user

      get "/application"

      assert_response :success
      assert_select "h1", text: "Welcome, #{@user.display_name}"
      assert_select "#organizations > li", count: 2
      assert_select "#organizations > li:first-child a[href='/application/organizations/#{moduler_organizations(:acme).id}']", text: /Acme.*Owner/m
      assert_select "#organizations > li:last-child a[href='/application/organizations/#{globex.id}']", text: /Globex/
      assert_select "aside", count: 0
    end

    test "index tells a user without organizations to ask an administrator" do
      @user.memberships.delete_all
      sign_in_as @user

      get "/application"

      assert_response :success
      assert_select "#organizations", count: 0
      assert_match "You don&#39;t belong to any organization yet.", response.body
    end
  end
end
