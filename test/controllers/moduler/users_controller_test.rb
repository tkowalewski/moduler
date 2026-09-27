require "test_helper"

module Moduler
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
    end

    test "new renders the registration form when not authenticated" do
      get "/moduler/user/new"

      assert_response :success
      assert_select "form"
    end

    test "new redirects to root when already authenticated" do
      sign_in_as @user

      get "/moduler/user/new"

      assert_redirected_to "/moduler/"
    end

    test "create with valid params creates a new user" do
      assert_difference "Moduler::User.count", 1 do
        post "/moduler/user", params: {
          user: {
            email_address: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with valid params redirects to the login page" do
      post "/moduler/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_redirected_to "/moduler/session/new"
    end

    test "create with valid params sets a success flash notice" do
      post "/moduler/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_equal I18n.t("moduler.users.create.success"), flash[:notice]
    end

    test "create with valid params persists the correct email address" do
      post "/moduler/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert Moduler::User.exists?(email_address: "newuser@example.com")
    end

    test "create with duplicate email re-renders the registration form" do
      post "/moduler/user", params: {
        user: {
          email_address: @user.email_address,
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with duplicate email does not create a new user" do
      assert_no_difference "Moduler::User.count" do
        post "/moduler/user", params: {
          user: {
            email_address: @user.email_address,
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with mismatched passwords re-renders the registration form" do
      post "/moduler/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "different_password"
        }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with mismatched passwords does not create a new user" do
      assert_no_difference "Moduler::User.count" do
        post "/moduler/user", params: {
          user: {
            email_address: "newuser@example.com",
            password: "password123",
            password_confirmation: "different_password"
          }
        }
      end
    end

    test "create with blank email re-renders the registration form" do
      post "/moduler/user", params: {
        user: {
          email_address: "",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with blank email does not create a new user" do
      assert_no_difference "Moduler::User.count" do
        post "/moduler/user", params: {
          user: {
            email_address: "",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with invalid email format re-renders the registration form" do
      post "/moduler/user", params: {
        user: {
          email_address: "not-a-valid-email",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with invalid email format does not create a new user" do
      assert_no_difference "Moduler::User.count" do
        post "/moduler/user", params: {
          user: {
            email_address: "not-a-valid-email",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with blank password re-renders the registration form" do
      post "/moduler/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "",
          password_confirmation: ""
        }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with blank password does not create a new user" do
      assert_no_difference "Moduler::User.count" do
        post "/moduler/user", params: {
          user: {
            email_address: "newuser@example.com",
            password: "",
            password_confirmation: ""
          }
        }
      end
    end

    private

    def sign_in_as(user, password: "password123")
      post "/moduler/session", params: {
        user: { email_address: user.email_address, password: password }
      }
    end
  end
end
