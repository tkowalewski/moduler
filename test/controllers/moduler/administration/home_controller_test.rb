require "test_helper"

module Moduler
  module Administration
    class HomeControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "index redirects an unauthenticated user to the sign-in page" do
        get "/application/administration"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page with an alert" do
        sign_in_as @member

        get "/application/administration"

        assert_redirected_to "/application/"
        assert_equal I18n.t("moduler.flash.not_authorized"), flash[:alert]
      end

      test "index succeeds for an administrator" do
        sign_in_as @administrator

        get "/application/administration"

        assert_response :success
      end
    end
  end
end
