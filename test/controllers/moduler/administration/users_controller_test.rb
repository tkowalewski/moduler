require "test_helper"

module Moduler
  module Administration
    class UsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/users"

        assert_redirected_to "/application/"
      end

      test "index succeeds for an administrator" do
        sign_in_as @administrator

        get "/application/administration/users"

        assert_response :success
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/users/new"

        assert_redirected_to "/application/"
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        post "/application/administration/users"

        assert_redirected_to "/application/"
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/users/#{@member.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        patch "/application/administration/users/#{@member.id}"

        assert_redirected_to "/application/"
      end
    end
  end
end
