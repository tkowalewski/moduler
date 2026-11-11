require "test_helper"

module Moduler
  class SentEmailTest < ActiveSupport::TestCase
    test "is valid without a user" do
      assert Moduler::SentEmail.new(to_address: "someone@example.com", subject: "Hi", body: "<p>Hi</p>").valid?
    end

    %i[ to_address subject body ].each do |attribute|
      test "is invalid without #{attribute}" do
        sent_email = Moduler::SentEmail.new(to_address: "someone@example.com", subject: "Hi", body: "<p>Hi</p>", attribute => "")

        assert_not sent_email.valid?
        assert_includes sent_email.errors[attribute], "can't be blank"
      end
    end

    test "destroying the user keeps their sent emails" do
      sent_email = moduler_sent_emails(:default_newsletter)

      moduler_users(:default).destroy!

      assert_nil sent_email.reload.user
    end
  end
end
