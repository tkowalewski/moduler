require "test_helper"

module Moduler
  class UserTest < ActiveSupport::TestCase
    test "is valid with all required attributes" do
      user = Moduler::User.new(email_address: "valid@example.com", password: "password123")
      assert user.valid?
    end

    test "is invalid without an email address" do
      user = Moduler::User.new(password: "password123")
      assert_not user.valid?
      assert_includes user.errors[:email_address], "can't be blank"
    end

    test "is invalid with a blank email address" do
      user = Moduler::User.new(email_address: "", password: "password123")
      assert_not user.valid?
      assert_includes user.errors[:email_address], "can't be blank"
    end

    test "is invalid with a duplicate email address" do
      existing = moduler_users(:default)
      user = Moduler::User.new(email_address: existing.email_address, password: "password123")
      assert_not user.valid?
      assert_includes user.errors[:email_address], "has already been taken"
    end

    test "can update other attributes without triggering the uniqueness error on itself" do
      user = moduler_users(:default)
      user.email_address = user.email_address # no change
      assert user.valid?
    end

    test "has a uniqueness validator on email_address" do
      validator_classes = Moduler::User.validators_on(:email_address).map(&:class)
      assert_includes validator_classes, ActiveRecord::Validations::UniquenessValidator
    end

    test "is invalid with a malformed email address" do
      invalid_addresses = [
        "plainstring",
        "missing_at_sign.com",
        "@nodomain",
        "missing@",
        "two@@signs.com"
      ]

      invalid_addresses.each do |bad_email|
        user = Moduler::User.new(email_address: bad_email, password: "password123")
        assert_not user.valid?, "Expected '#{bad_email}' to be invalid"
        assert user.errors[:email_address].any?,
               "Expected errors on :email_address for '#{bad_email}'"
      end
    end

    test "is valid with well-formed email addresses" do
      valid_addresses = [
        "user@example.com",
        "user+tag@example.org",
        "user.name@sub.domain.co.uk"
      ]

      valid_addresses.each do |good_email|
        user = Moduler::User.new(email_address: good_email, password: "password123")
        assert user.valid?, "Expected '#{good_email}' to be valid, got: #{user.errors.full_messages}"
      end
    end

    test "has a format validator on email_address" do
      validator_classes = Moduler::User.validators_on(:email_address).map(&:class)
      assert_includes validator_classes, ActiveModel::Validations::FormatValidator
    end

    test "is invalid without a password when creating a new record" do
      user = Moduler::User.new(email_address: "newuser@example.com")
      assert_not user.valid?
      assert user.errors[:password].any?
    end

    test "is invalid with a blank password when creating a new record" do
      user = Moduler::User.new(email_address: "newuser@example.com", password: "")
      assert_not user.valid?
      assert user.errors[:password].any?
    end

    test "is invalid when password_confirmation does not match password" do
      user = Moduler::User.new(
        email_address: "newuser@example.com",
        password: "password123",
        password_confirmation: "different_password"
      )
      assert_not user.valid?
      assert user.errors[:password_confirmation].any?
    end

    test "is valid when password_confirmation matches password" do
      user = Moduler::User.new(
        email_address: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
      assert user.valid?
    end

    test "does not require password when updating other attributes on a persisted record" do
      user = moduler_users(:default)
      user.email_address = "updated@example.com"
      assert user.valid?
    end

    test "sets password_digest when a password is assigned" do
      user = Moduler::User.new(email_address: "newuser@example.com", password: "password123")
      assert_not_nil user.password_digest
    end

    test "password_digest changes when a new password is set" do
      user = moduler_users(:default)
      old_digest = user.password_digest

      user.update!(password: "brand_new_password")

      assert_not_equal old_digest, user.reload.password_digest
    end

    test "authenticate returns the user when the correct password is given" do
      user = moduler_users(:default)
      assert_equal user, user.authenticate("password123")
    end

    test "authenticate returns false when an incorrect password is given" do
      user = moduler_users(:default)
      assert_equal false, user.authenticate("wrong_password")
    end

    test "authenticate_by returns the user with correct credentials" do
      user = moduler_users(:default)
      found = Moduler::User.authenticate_by(
        email_address: user.email_address,
        password: "password123"
      )
      assert_equal user, found
    end

    test "authenticate_by returns nil when the password is wrong" do
      user = moduler_users(:default)
      result = Moduler::User.authenticate_by(
        email_address: user.email_address,
        password: "wrong_password"
      )
      assert_nil result
    end

    test "authenticate_by returns nil when the email address is unknown" do
      result = Moduler::User.authenticate_by(
        email_address: "ghost@example.com",
        password: "password123"
      )
      assert_nil result
    end

    test "authenticate_by returns nil when both credentials are wrong" do
      result = Moduler::User.authenticate_by(
        email_address: "ghost@example.com",
        password: "wrong_password"
      )
      assert_nil result
    end

    test "responds to sessions" do
      user = moduler_users(:default)
      assert_respond_to user, :sessions
    end

    test "sessions returns a collection proxy" do
      user = moduler_users(:default)
      assert_kind_of ActiveRecord::Associations::CollectionProxy, user.sessions
    end

    test "sessions returns all sessions belonging to the user" do
      user = moduler_users(:default)
      assert_includes user.sessions, moduler_sessions(:active)
      assert_includes user.sessions, moduler_sessions(:signed_out)
    end

    test "sessions does not include sessions from other users" do
      other_user = Moduler::User.create!(
        email_address: "other@example.com",
        password: "password123"
      )
      other_session = other_user.sessions.create!(
        ip_address: "10.0.0.1",
        signed_in_at: Time.current
      )

      user = moduler_users(:default)
      assert_not_includes user.sessions, other_session
    end

    test "destroying a user also destroys all associated sessions" do
      user = moduler_users(:default)
      session_ids = user.sessions.ids
      assert_not_empty session_ids

      user.destroy

      session_ids.each do |id|
        assert_not Moduler::Session.exists?(id),
                   "Expected session #{id} to have been destroyed with the user"
      end
    end

    test "destroying a user decreases the session count by the number of their sessions" do
      user = moduler_users(:default)
      user_session_count = user.sessions.count

      assert_difference "Moduler::Session.count", -user_session_count do
        user.destroy
      end
    end

    test "can be persisted with valid attributes" do
      assert_difference "Moduler::User.count", 1 do
        Moduler::User.create!(email_address: "brand_new@example.com", password: "password123")
      end
    end

    test "cannot be persisted without an email address" do
      assert_no_difference "Moduler::User.count" do
        Moduler::User.create(password: "password123")
      end
    end

    test "cannot be persisted with a duplicate email address" do
      existing = moduler_users(:default)

      assert_no_difference "Moduler::User.count" do
        Moduler::User.create(email_address: existing.email_address, password: "password123")
      end
    end

    test "cannot be persisted without a password" do
      assert_no_difference "Moduler::User.count" do
        Moduler::User.create(email_address: "nopassword@example.com")
      end
    end
  end
end
