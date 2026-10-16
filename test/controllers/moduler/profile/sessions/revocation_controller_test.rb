require "test_helper"

module Moduler
  module Profile
    module Sessions
      class RevocationControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = moduler_users(:default)
        end

        test "destroy redirects to the login page when not authenticated" do
          delete "/application/profile/sessions/revocation"

          assert_redirected_to "/application/session/new"
          assert moduler_sessions(:active).reload.active?
        end

        test "destroy revokes all active sessions of the current user" do
          sign_in_as @user
          other = @user.sessions.create!(signed_in_at: Time.current)

          delete "/application/profile/sessions/revocation"

          assert_empty @user.sessions.active
          assert_not other.reload.active?
          assert_not moduler_sessions(:active).reload.active?
        end

        test "destroy signs the user out of the current session" do
          sign_in_as @user

          delete "/application/profile/sessions/revocation"

          assert_redirected_to "/application/session/new"
          assert cookies[:session_id].blank?
        end

        test "destroy denies access with the revoked session afterwards" do
          sign_in_as @user

          delete "/application/profile/sessions/revocation"
          get "/application/profile/sessions"

          assert_redirected_to "/application/session/new"
        end

        test "destroy does not change already signed out sessions" do
          sign_in_as @user
          signed_out = moduler_sessions(:signed_out)

          assert_no_changes -> { signed_out.reload.signed_out_at } do
            delete "/application/profile/sessions/revocation"
          end
        end

        test "destroy does not revoke sessions of other users" do
          other_user = Moduler::User.create!(email_address: "other@domain.tld", password: "password123")
          foreign = other_user.sessions.create!(signed_in_at: Time.current)
          sign_in_as @user

          delete "/application/profile/sessions/revocation"

          assert foreign.reload.active?
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
end
