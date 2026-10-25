require "test_helper"

module Moduler
  module Administration
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @active = moduler_sessions(:active)
        @signed_out = moduler_sessions(:signed_out)
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

      test "index lists sessions of all users" do
        sign_in_as @administrator

        get "/application/administration/sessions"

        assert_select "#sessions > li", count: Moduler::Session.count
        assert_select "#sessions", text: /#{@member.email_address}/
        assert_select "#sessions", text: /#{@administrator.email_address}/
      end

      test "index renders the revoke action only for active sessions" do
        sign_in_as @administrator

        get "/application/administration/sessions"

        assert_select "form[action='/application/administration/sessions/#{@active.id}'] input[name='_method'][value='delete']"
        assert_select "form[action='/application/administration/sessions/#{@signed_out.id}']", count: 0
      end

      test "index does not render create or revoke all actions" do
        sign_in_as @administrator

        get "/application/administration/sessions"

        assert_select "a[href='/application/administration/sessions/new']", count: 0
        assert_select "form[action='/application/administration/sessions'][method='post']", count: 0
      end

      test "index filters sessions by email address" do
        sign_in_as @administrator

        get "/application/administration/sessions", params: { filter: { query: "test@" } }

        assert_response :success
        assert_select "#sessions > li", count: @member.sessions.count
        assert_select "#sessions", text: /#{@administrator.email_address}/, count: 0
      end

      test "index filters sessions by ip address" do
        sign_in_as @administrator

        get "/application/administration/sessions", params: { filter: { query: "192.168.1.1" } }

        assert_response :success
        assert_select "#sessions > li", count: 1
        assert_select "li##{ActionView::RecordIdentifier.dom_id(@signed_out)}"
      end

      test "index renders an empty state when no sessions match the query" do
        sign_in_as @administrator

        get "/application/administration/sessions", params: { filter: { query: "nobody@example.com" } }

        assert_response :success
        assert_select "#sessions", count: 0
      end

      test "index paginates sessions" do
        sign_in_as @administrator
        12.times { @member.sessions.create!(ip_address: "10.0.0.1", user_agent: "Test", signed_in_at: Time.current) }

        get "/application/administration/sessions"

        assert_select "#sessions > li", count: 10
        assert_select "nav[aria-label='Pagination'] a[rel='next']"

        get "/application/administration/sessions", params: { page: 2 }

        assert_select "#sessions > li", count: Moduler::Session.count - 10
      end

      test "destroy revokes a session and redirects to the list" do
        sign_in_as @administrator

        delete "/application/administration/sessions/#{@active.id}"

        assert_redirected_to "/application/administration/sessions"
        assert_equal I18n.t("moduler.administration.sessions.destroy.notice"), flash[:notice]
        assert_not @active.reload.active?
      end

      test "destroy signs out the administrator when revoking the current session" do
        sign_in_as @administrator
        current = @administrator.sessions.order(:created_at).last

        delete "/application/administration/sessions/#{current.id}"

        assert_redirected_to "/application/session/new"
        assert_not current.reload.active?
      end

      test "destroy responds with not found for a signed out session" do
        sign_in_as @administrator

        assert_no_changes -> { @signed_out.reload.signed_out_at } do
          delete "/application/administration/sessions/#{@signed_out.id}"
        end

        assert_response :not_found
      end

      test "destroy responds with not found for an unknown session" do
        sign_in_as @administrator

        delete "/application/administration/sessions/#{SecureRandom.uuid}"

        assert_response :not_found
      end

      test "destroy redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @active.reload.signed_out_at } do
          delete "/application/administration/sessions/#{@active.id}"
        end

        assert_redirected_to "/application/"
      end
    end
  end
end
