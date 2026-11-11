require "test_helper"

module Moduler
  class EmailMailerTest < ActionMailer::TestCase
    setup do
      @user = moduler_users(:default)
      @email = moduler_emails(:newsletter)
    end

    def deliver
      Moduler::EmailMailer.with(email: @email, user: @user).custom.tap(&:deliver_now)
    end

    test "sends the email to the user" do
      mail = deliver

      assert_equal [ "test@domain.tld" ], mail.to
      assert_equal "November news", mail.subject
      assert_equal [ "from@example.com" ], mail.from
      assert_includes mail.html_part.body.decoded, "Hello, here is what is new."
      assert_includes mail.text_part.body.decoded, "Hello, here is what is new."
    end

    test "sends from the sender of the email when set" do
      @email.update!(sender: "Support <support@example.com>")

      assert_equal [ "support@example.com" ], deliver.from
    end

    test "keeps image URLs of the body as they are" do
      @email.update!(body: "![logo](https://app.example.com/rails/active_storage/blobs/redirect/abc/logo.png)")

      assert_includes deliver.html_part.body.decoded, %(src="https://app.example.com/rails/active_storage/blobs/redirect/abc/logo.png")
    end

    test "attaches the files of the email" do
      @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")

      assert_equal [ "terms.pdf" ], deliver.attachments.map(&:filename)
    end

    test "records the delivered email for the user" do
      assert_difference -> { @user.sent_emails.count }, 1 do
        deliver
      end

      sent_email = @user.sent_emails.order(:created_at).last
      assert_equal "test@domain.tld", sent_email.to_address
      assert_equal "November news", sent_email.subject
      assert_includes sent_email.body, "Hello, here is what is new."
    end

    test "records the attachments of the delivered email" do
      @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")

      deliver

      assert_equal [ "terms.pdf" ], @user.sent_emails.order(:created_at).last.attachments.map { |attachment| attachment.filename.to_s }
    end

    test "does not record an email that was not delivered" do
      assert_no_difference -> { Moduler::SentEmail.count } do
        Moduler::EmailMailer.with(email: @email, user: @user).custom.message
      end
    end

    class BlankSubjectMailer < Moduler::ApplicationMailer
      def notice
        mail(to: "someone@example.com", subject: "", body: "Hello")
      end
    end

    test "a failure to record the email does not fail the delivery and is reported" do
      assert_no_difference -> { Moduler::SentEmail.count } do
        assert_error_reported(ActiveRecord::RecordInvalid) do
          assert_emails 1 do
            BlankSubjectMailer.notice.deliver_now
          end
        end
      end
    end
  end
end
