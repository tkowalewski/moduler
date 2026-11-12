require "test_helper"

module Moduler
  class ProfileControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
    end

    test "edit redirects to the login page when not authenticated" do
      get "/application/profile/edit"

      assert_redirected_to "/application/session/new"
    end

    test "edit renders the profile form when authenticated" do
      sign_in_as @user

      get "/application/profile/edit"

      assert_response :success
      assert_select "form[action='/application/profile']"
      assert_select "input[type='password'][name='user[password]']"
      assert_select "input[type='password'][name='user[password_confirmation]']"
      assert_select "input[type='password'][name='user[password_challenge]']"
    end

    test "edit renders the email address as a disabled field" do
      sign_in_as @user

      get "/application/profile/edit"

      assert_select "input[type='email'][name='user[email_address]'][value='#{@user.email_address}'][disabled]"
    end

    test "header links the current user's email address to the profile page" do
      sign_in_as @user

      get "/application/profile/edit"

      assert_select "nav a[href='/application/profile/edit']", text: @user.email_address
    end

    test "header links the current user's name to the profile page when present" do
      @user.update!(name: "Jan Kowalski")
      sign_in_as @user

      get "/application/profile/edit"

      assert_select "nav a[href='/application/profile/edit']", text: "Jan Kowalski"
    end

    test "edit renders the name field" do
      @user.update!(name: "Jan Kowalski")
      sign_in_as @user

      get "/application/profile/edit"

      assert_select "input[type='text'][name='user[name]'][value='Jan Kowalski']"
    end

    test "update changes the name without the current password" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { name: "Jan Kowalski", password_challenge: "", password: "", password_confirmation: "" }
      }

      assert_redirected_to "/application/profile/edit"
      assert_equal "Jan Kowalski", @user.reload.name
      assert @user.authenticate("password123")
    end

    test "update removes the name" do
      @user.update!(name: "Jan Kowalski")
      sign_in_as @user

      patch "/application/profile", params: { user: { name: "", password_challenge: "", password: "", password_confirmation: "" } }

      assert_redirected_to "/application/profile/edit"
      assert_nil @user.reload.name
    end

    test "update changes the name and password together" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { name: "Jan Kowalski", password_challenge: "password123", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_redirected_to "/application/profile/edit"
      @user.reload
      assert_equal "Jan Kowalski", @user.name
      assert @user.authenticate("new_password1")
    end

    test "update with a too long name re-renders the form" do
      sign_in_as @user

      patch "/application/profile", params: { user: { name: "a" * 101, password_challenge: "", password: "", password_confirmation: "" } }

      assert_response :unprocessable_entity
      assert_nil @user.reload.name
    end

    test "edit renders the time zone select with the application default" do
      sign_in_as @user

      get "/application/profile/edit"

      assert_select "select[name='user[time_zone]']" do
        assert_select "option[value='']", text: "Application default #{Time.zone_default}"
        assert_select "option[value='Warsaw']", text: ActiveSupport::TimeZone["Warsaw"].to_s
      end
    end

    test "update changes the time zone without the current password" do
      sign_in_as @user

      patch "/application/profile", params: { user: { time_zone: "Warsaw", password_challenge: "", password: "", password_confirmation: "" } }

      assert_redirected_to "/application/profile/edit"
      assert_equal "Warsaw", @user.reload.time_zone
      follow_redirect!
      assert_select "select[name='user[time_zone]'] option[value='Warsaw'][selected]"
    end

    test "update resets the time zone to the application default" do
      @user.update!(time_zone: "Warsaw")
      sign_in_as @user

      patch "/application/profile", params: { user: { time_zone: "", password_challenge: "", password: "", password_confirmation: "" } }

      assert_redirected_to "/application/profile/edit"
      assert_nil @user.reload.time_zone
    end

    test "update with an unknown time zone re-renders the form" do
      sign_in_as @user

      patch "/application/profile", params: { user: { time_zone: "Mars/Olympus_Mons", password_challenge: "", password: "", password_confirmation: "" } }

      assert_response :unprocessable_entity
      assert_nil @user.reload.time_zone
    end

    test "update redirects to the login page when not authenticated" do
      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_redirected_to "/application/session/new"
      assert @user.reload.authenticate("password123")
    end

    test "update with valid params changes the password" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_redirected_to "/application/profile/edit"
      assert @user.reload.authenticate("new_password1")
    end

    test "update with valid params shows a notice in a flash toast" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "new_password1", password_confirmation: "new_password1" }
      }
      follow_redirect!

      assert_select "[data-controller='flash']", text: I18n.t("moduler.profile.update.notice")
    end

    test "update with a password change signs out other active sessions" do
      other_session = moduler_sessions(:active)
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_not_nil other_session.reload.signed_out_at
    end

    test "update with a password change keeps the current session active" do
      sign_in_as @user
      current_session = @user.sessions.order(:created_at).last

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_nil current_session.reload.signed_out_at
      get "/application/profile/edit"
      assert_response :success
    end

    test "update with a password change does not touch already signed out sessions" do
      signed_out_session = moduler_sessions(:signed_out)
      signed_out_at = signed_out_session.signed_out_at
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_equal signed_out_at.to_i, signed_out_session.reload.signed_out_at.to_i
    end

    test "update without a new password does not sign out other sessions" do
      other_session = moduler_sessions(:active)
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "", password_confirmation: "" }
      }

      assert_redirected_to "/application/profile/edit"
      assert_nil other_session.reload.signed_out_at
      assert @user.reload.authenticate("password123")
    end

    test "update with a wrong current password does not change the password" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "wrong_password", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_response :unprocessable_entity
      assert @user.reload.authenticate("password123")
    end

    test "update with a wrong current password does not sign out other sessions" do
      other_session = moduler_sessions(:active)
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "wrong_password", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_nil other_session.reload.signed_out_at
    end

    test "update with a blank current password does not change the password" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "", password: "new_password1", password_confirmation: "new_password1" }
      }

      assert_response :unprocessable_entity
      assert @user.reload.authenticate("password123")
    end

    test "update with mismatched password confirmation does not change the password" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "new_password1", password_confirmation: "other_password1" }
      }

      assert_response :unprocessable_entity
      assert @user.reload.authenticate("password123")
    end

    test "update with a too short password does not change the password" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "short1", password_confirmation: "short1" }
      }

      assert_response :unprocessable_entity
      assert @user.reload.authenticate("password123")
    end

    test "update ignores the email address param" do
      sign_in_as @user

      patch "/application/profile", params: {
        user: { email_address: "hacked@example.com", password_challenge: "password123", password: "", password_confirmation: "" }
      }

      assert_equal "test@domain.tld", @user.reload.email_address
    end

    test "update without user params responds with bad request" do
      sign_in_as @user

      patch "/application/profile", params: {}

      assert_response :bad_request
    end

    private

    def sign_in_as(user, password: "password123")
      post "/application/session", params: {
        user: { email_address: user.email_address, password: password }
      }
    end
  end
end
