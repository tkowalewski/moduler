require "test_helper"

module Moduler
  module Administration
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/sessions"

        assert_redirected_to "/application/"
      end

      test "index succeeds for an administrator" do
        sign_in_as @administrator

        get "/application/administration/sessions"

        assert_response :success
      end

      test "destroy redirects a member to the home page" do
        sign_in_as @member

        delete "/application/administration/sessions/#{Moduler::Session.first.id}"

        assert_redirected_to "/application/"
      end
    end
  end
end
