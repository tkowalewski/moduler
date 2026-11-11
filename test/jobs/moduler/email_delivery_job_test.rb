require "test_helper"

module Moduler
  class EmailDeliveryJobTest < ActiveJob::TestCase
    include ActionMailer::TestHelper

    setup do
      @user_email = Moduler::UserEmail.create!(user: moduler_users(:administrator), email: moduler_emails(:newsletter))
    end

    test "delivers the email and marks it as sent" do
      freeze_time do
        assert_emails 1 do
          Moduler::EmailDeliveryJob.perform_now(@user_email)
        end

        assert_equal Time.current, @user_email.reload.sent_at
      end
    end

    test "does not deliver an email that has already been sent" do
      assert_no_emails do
        Moduler::EmailDeliveryJob.perform_now(moduler_user_emails(:default_newsletter))
      end
    end

    test "is discarded when the user email no longer exists" do
      Moduler::EmailDeliveryJob.perform_later(@user_email)
      @user_email.destroy!

      assert_nothing_raised { perform_enqueued_jobs }
    end
  end
end
