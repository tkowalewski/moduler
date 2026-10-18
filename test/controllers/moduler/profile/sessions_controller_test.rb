require "test_helper"

module Moduler
  module Profile
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = moduler_users(:default)
      end

      test "index redirects to the login page when not authenticated" do
        get "/application/profile/sessions"

        assert_redirected_to "/application/session/new"
      end

      test "index lists the current user's sessions" do
        sign_in_as @user

        get "/application/profile/sessions"

        assert_response :success
        assert_select "#sessions > li", count: @user.sessions.count
      end

      test "index does not list sessions of other users" do
        other_user = Moduler::User.create!(email_address: "other@domain.tld", password: "password123")
        other_user.sessions.create!(signed_in_at: Time.current, ip_address: "10.0.0.99")
        sign_in_as @user

        get "/application/profile/sessions"

        assert_response :success
        assert_no_match "10.0.0.99", response.body
      end

      test "index renders the revoke all button" do
        sign_in_as @user

        get "/application/profile/sessions"

        assert_select "form[action='/application/profile/sessions/revocation'] input[name='_method'][value='delete']"
      end

      test "index paginates sessions" do
        sign_in_as @user
        moduler_sessions(:active).update!(signed_out_at: Time.current)
        25.times { @user.sessions.create!(signed_in_at: Time.current, signed_out_at: Time.current) }

        get "/application/profile/sessions"

        assert_response :success
        assert_select "#sessions > li", minimum: 1
        assert_select "nav[aria-label='Pagination'] a[rel='next']"

        get "/application/profile/sessions", params: { page: 2 }

        assert_response :success
        assert_select "#sessions > li", minimum: 1
      end

      test "destroy redirects to the login page when not authenticated" do
        session = moduler_sessions(:active)

        delete "/application/profile/sessions/#{session.id}"

        assert_redirected_to "/application/session/new"
        assert session.reload.active?
      end

      test "destroy revokes another active session" do
        sign_in_as @user
        other = @user.sessions.create!(signed_in_at: Time.current)

        delete "/application/profile/sessions/#{other.id}"

        assert_redirected_to "/application/profile/sessions"
        assert_not other.reload.active?
      end

      test "destroy of another session keeps the current session active" do
        sign_in_as @user
        current = current_session
        other = @user.sessions.create!(signed_in_at: Time.current)

        delete "/application/profile/sessions/#{other.id}"

        assert current.reload.active?
        assert cookies[:session_id].present?
      end

      test "destroy of the current session signs the user out" do
        sign_in_as @user
        current = current_session

        delete "/application/profile/sessions/#{current.id}"

        assert_redirected_to "/application/session/new"
        assert_not current.reload.active?
        assert cookies[:session_id].blank?
      end

      test "destroy of an already signed out session responds with not found" do
        sign_in_as @user
        signed_out = moduler_sessions(:signed_out)

        assert_no_changes -> { signed_out.reload.signed_out_at } do
          delete "/application/profile/sessions/#{signed_out.id}"
        end

        assert_response :not_found
      end

      test "destroy of another user's session responds with not found" do
        other_user = Moduler::User.create!(email_address: "other@domain.tld", password: "password123")
        foreign = other_user.sessions.create!(signed_in_at: Time.current)
        sign_in_as @user

        delete "/application/profile/sessions/#{foreign.id}"

        assert_response :not_found
        assert foreign.reload.active?
      end

      private

      def sign_in_as(user, password: "password123")
        post "/application/session", params: {
          user: { email_address: user.email_address, password: password }
        }
      end

      def current_session
        @user.sessions.order(:created_at).last
      end
    end
  end
end
