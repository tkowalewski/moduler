require "test_helper"

module Moduler
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
    end

    test "new renders the login form when not authenticated" do
      get "/moduler/session/new"

      assert_response :success
      assert_select "form"
    end

    test "new redirects to root when already authenticated" do
      sign_in_as @user

      get "/moduler/session/new"

      assert_redirected_to "/moduler"
    end

    test "create with valid credentials redirects to root" do
      post "/moduler/session", params: {
        user: { email_address: @user.email_address, password: "password123" }
      }

      assert_redirected_to "/moduler"
    end

    test "create with valid credentials creates a new session record" do
      assert_difference "Moduler::Session.count", 1 do
        post "/moduler/session", params: {
          user: { email_address: @user.email_address, password: "password123" }
        }
      end
    end

    test "create with valid credentials sets the session_id cookie" do
      post "/moduler/session", params: {
        user: { email_address: @user.email_address, password: "password123" }
      }

      assert_not_nil cookies[:session_id]
    end

    test "create with valid credentials stores ip_address and user_agent on the session" do
      post "/moduler/session",
        params: { user: { email_address: @user.email_address, password: "password123" } },
        headers: { "User-Agent" => "TestBrowser/1.0" }

      session = Moduler::Session.order(created_at: :desc).first
      assert_not_nil session.ip_address
      assert_equal "TestBrowser/1.0", session.user_agent
    end

    test "create with invalid password re-renders the login form" do
      post "/moduler/session", params: {
        user: { email_address: @user.email_address, password: "wrong_password" }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with invalid password does not create a session record" do
      assert_no_difference "Moduler::Session.count" do
        post "/moduler/session", params: {
          user: { email_address: @user.email_address, password: "wrong_password" }
        }
      end
    end

    test "create with unknown email re-renders the login form" do
      post "/moduler/session", params: {
        user: { email_address: "nobody@example.com", password: "password123" }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with unknown email does not create a session record" do
      assert_no_difference "Moduler::Session.count" do
        post "/moduler/session", params: {
          user: { email_address: "nobody@example.com", password: "password123" }
        }
      end
    end

    test "create with invalid credentials shows an error message" do
      post "/moduler/session", params: {
        user: { email_address: @user.email_address, password: "wrong_password" }
      }

      assert_match I18n.t("moduler.sessions.create.invalid_credentials"), response.body
    end

    test "destroy when authenticated redirects to the login page" do
      sign_in_as @user

      delete "/moduler/session"

      assert_redirected_to "/moduler/session/new"
    end

    test "destroy when authenticated clears the session_id cookie" do
      sign_in_as @user

      delete "/moduler/session"

      assert cookies[:session_id].blank?
    end

    test "destroy when authenticated marks the session as signed out" do
      sign_in_as @user
      active_count_before = @user.sessions.where(signed_out_at: nil).count

      delete "/moduler/session"

      assert_equal active_count_before - 1, @user.sessions.where(signed_out_at: nil).count
    end

    test "destroy when authenticated sets signed_out_at timestamp on the session" do
      sign_in_as @user
      created_session = @user.sessions.order(:created_at).last

      delete "/moduler/session"

      assert_not_nil created_session.reload.signed_out_at
    end

    test "destroy when not authenticated redirects to the login page" do
      delete "/moduler/session"

      assert_redirected_to "/moduler/session/new"
    end

    private

    def sign_in_as(user, password: "password123")
      post "/moduler/session", params: {
        user: { email_address: user.email_address, password: password }
      }
    end
  end
end
