require "test_helper"

module Moduler
  module Profile
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = moduler_users(:default)
      end

      test "index paginates sessions" do
        sign_in_as @user
        moduler_sessions(:active).update!(signed_out_at: Time.current)
        25.times { @user.sessions.create!(signed_in_at: Time.current, signed_out_at: Time.current) }

        get "/application/profile/sessions"

        assert_response :success
        assert_select "tbody tr", minimum: 1
        assert_select "nav[aria-label='Pagination'] a[rel='next']"

        get "/application/profile/sessions", params: { page: 2 }

        assert_response :success
        assert_select "tbody tr", minimum: 1
      end

      test "destroy revokes another active session" do
        sign_in_as @user
        other = @user.sessions.create!(signed_in_at: Time.current)

        delete "/application/profile/sessions/#{other.id}"

        assert_redirected_to "/application/profile/sessions"
        assert_not other.reload.active?
      end

      private

      def sign_in_as(user, password: "password123")
        post "/application/session", params: {
          user: { email_address: user.email_address, password: password }
        }
      end
    end
  end
end
