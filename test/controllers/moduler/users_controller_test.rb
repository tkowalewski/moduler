require "test_helper"

module Moduler
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
    end

    test "new renders the registration form when not authenticated" do
      get "/application/user/new"

      assert_response :success
      assert_select "form"
    end

    test "new redirects to root when already authenticated" do
      sign_in_as @user

      get "/application/user/new"

      assert_redirected_to "/application/"
    end

    test "create with valid params creates a new user" do
      assert_difference "Moduler::User.count", 1 do
        post "/application/user", params: {
          user: {
            email_address: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with valid params redirects to the login page" do
      post "/application/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_redirected_to "/application/session/new"
    end

    test "create with valid params sets a success flash notice" do
      post "/application/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_equal I18n.t("moduler.users.create.success"), flash[:notice]
    end

    test "create with valid params persists the correct email address" do
      post "/application/user", params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert Moduler::User.exists?(email_address: "newuser@example.com")
    end

    test "create normalizes the email address by stripping and downcasing it" do
      post "/application/user", params: {
        user: {
          email_address: "  NewUser@Example.COM  ",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert Moduler::User.exists?(email_address: "newuser@example.com")
    end

    test "create with a differently cased duplicate email re-renders the registration form" do
      post "/application/user", params: {
        user: {
          email_address: "  TEST@DOMAIN.TLD ",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_response :success
      assert_select "form"
    end

    test "create with a differently cased duplicate email does not create a new user" do
      assert_no_difference "Moduler::User.count" do
        post "/application/user", params: {
          user: {
            email_address: "Test@Domain.tld",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with duplicate email re-renders the registration form" do
      post "/application/user", params: {
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
        post "/application/user", params: {
          user: {
            email_address: @user.email_address,
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with mismatched passwords re-renders the registration form" do
      post "/application/user", params: {
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
        post "/application/user", params: {
          user: {
            email_address: "newuser@example.com",
            password: "password123",
            password_confirmation: "different_password"
          }
        }
      end
    end

    test "create with blank email re-renders the registration form" do
      post "/application/user", params: {
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
        post "/application/user", params: {
          user: {
            email_address: "",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with invalid email format re-renders the registration form" do
      post "/application/user", params: {
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
        post "/application/user", params: {
          user: {
            email_address: "not-a-valid-email",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    test "create with blank password re-renders the registration form" do
      post "/application/user", params: {
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
        post "/application/user", params: {
          user: {
            email_address: "newuser@example.com",
            password: "",
            password_confirmation: ""
          }
        }
      end
    end

    test "create is rate limited after 10 sign-ups from the same ip" do
      10.times do |i|
        post "/application/user", params: {
          user: {
            email_address: "user#{i}@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      post "/application/user", params: {
        user: {
          email_address: "eleventh@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_redirected_to "/application/user/new"
      assert_equal I18n.t("moduler.users.create.rate_limited"), flash[:alert]
    end

    test "create is rate limited after 5 sign-ups for the same email address" do
      5.times do
        post "/application/user", params: {
          user: {
            email_address: "taken@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      post "/application/user", params: {
        user: {
          email_address: "taken@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      assert_redirected_to "/application/user/new"
      assert_equal I18n.t("moduler.users.create.rate_limited"), flash[:alert]
    end

    private

    def sign_in_as(user, password: "password123")
      post "/application/session", params: {
        user: { email_address: user.email_address, password: password }
      }
    end
  end
end
