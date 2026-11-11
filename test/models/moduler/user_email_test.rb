require "test_helper"

module Moduler
  class UserEmailTest < ActiveSupport::TestCase
    test "is invalid for a user the email has already been queued for" do
      user_email = Moduler::UserEmail.new(user: moduler_users(:default), email: moduler_emails(:newsletter))

      assert_not user_email.valid?
      assert_includes user_email.errors[:user], "has already been taken"
    end

    test "is invalid without a user or an email" do
      user_email = Moduler::UserEmail.new

      assert_not user_email.valid?
      assert_includes user_email.errors[:user], "must exist"
      assert_includes user_email.errors[:email], "must exist"
    end

    test "sent? tells whether the email has been delivered" do
      assert moduler_user_emails(:default_newsletter).sent?
      assert_not Moduler::UserEmail.new.sent?
    end

    test "sent returns delivered user emails" do
      queued = Moduler::UserEmail.create!(user: moduler_users(:administrator), email: moduler_emails(:newsletter))

      assert_includes Moduler::UserEmail.sent, moduler_user_emails(:default_newsletter)
      assert_not_includes Moduler::UserEmail.sent, queued
    end
  end
end
