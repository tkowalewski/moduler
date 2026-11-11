require "test_helper"

module Moduler
  class EmailTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @email = moduler_emails(:newsletter)
      @user = moduler_users(:default)
      @other = Moduler::User.create!(email_address: "other@domain.tld", password: "password123", name: "Other User")
    end

    def build_email(**attributes)
      Moduler::Email.new(subject: "Hello", kind: "custom", body: "Hello there", **attributes)
    end

    test "is valid with all required attributes" do
      email = build_email
      assert email.valid?, "Expected email to be valid, got: #{email.errors.full_messages}"
    end

    %i[ subject kind body ].each do |attribute|
      test "is invalid without #{attribute}" do
        email = build_email(attribute => "")
        assert_not email.valid?
        assert_includes email.errors[attribute], "can't be blank"
      end
    end

    test "is invalid with an unknown kind" do
      email = build_email(kind: "promotion")
      assert_not email.valid?
      assert_includes email.errors[:kind], "is not included in the list"
    end

    test "is valid without an event and stores a blank event as nil" do
      email = build_email(event: " ")
      assert email.valid?
      assert_nil email.event
    end

    test "strips the event" do
      assert_equal "order.paid", build_email(event: " order.paid ").event
    end

    [ "order", "order.paid", "billing.invoice_2.overdue" ].each do |event|
      test "is valid with event #{event.inspect}" do
        assert build_email(event: event).valid?
      end
    end

    [ "Order.Paid", "order paid", "order..paid", ".order", "order.", "order-paid" ].each do |event|
      test "is invalid with event #{event.inspect}" do
        email = build_email(event: event)
        assert_not email.valid?
        assert_includes email.errors[:event], "is invalid"
      end
    end

    test "is invalid with an event already used by another email" do
      email = build_email(event: "user.signup")
      assert_not email.valid?
      assert_includes email.errors[:event], "has already been taken"
    end

    test "database rejects a duplicate event" do
      assert_raises(ActiveRecord::RecordNotUnique) { build_email(event: "user.signup").save!(validate: false) }
    end

    test "allows many emails without an event" do
      build_email.save!
      assert build_email.valid?
    end

    test "strips the sender and stores a blank sender as nil" do
      assert_equal "Support <support@example.com>", build_email(sender: "  Support <support@example.com> ").sender
      assert_nil build_email(sender: " ").sender
    end

    test "rejects images with a disallowed content type" do
      email = build_email
      email.images.attach(io: file_fixture("document.txt").open, filename: "image.txt", content_type: "text/plain")
      assert_not email.valid?
      assert email.errors[:images].any?
    end

    test "to_html renders markdown and sanitizes scripts" do
      email = build_email(body: "# Hi\n\n<script>alert(1)</script>")
      html = email.to_html

      assert_includes html, "<h1>Hi</h1>"
      assert_not_includes html, "<script>"
    end

    test "deliver_to queues the email for each user and returns the count" do
      assert_enqueued_jobs 1, only: Moduler::EmailDeliveryJob do
        assert_equal 1, @email.deliver_to([ @other ])
      end
      assert @email.user_emails.exists?(user: @other)
    end

    test "deliver_to skips users the email has already been queued for" do
      assert_no_enqueued_jobs do
        assert_equal 0, @email.deliver_to([ @user ])
      end
    end

    test "deliver_event sends the email of the event once" do
      assert_enqueued_jobs 1, only: Moduler::EmailDeliveryJob do
        Moduler::Email.deliver_event("user.signup", to: @other)
        Moduler::Email.deliver_event("user.signup", to: @other)
      end
    end

    test "deliver_event sends the email of any event defined in the administration" do
      email = build_email(event: "order.paid")
      email.save!

      assert_enqueued_jobs 1, only: Moduler::EmailDeliveryJob do
        Moduler::Email.deliver_event(:"order.paid", to: @other)
      end
      assert email.user_emails.exists?(user: @other)
    end

    test "deliver_event does nothing without an email for the event" do
      moduler_emails(:welcome).update!(event: nil)

      assert_no_enqueued_jobs do
        assert_nil Moduler::Email.deliver_event("user.signup", to: @other)
      end
    end

    test "sent_count counts users the email has been delivered to" do
      @email.user_emails.create!(user: @other)

      assert_equal 1, @email.sent_count
    end

    test "destroying the email deletes its user emails but keeps sent emails" do
      assert_difference -> { Moduler::UserEmail.count } => -1, -> { Moduler::SentEmail.count } => 0 do
        @email.destroy!
      end
    end

    test "search_by_query finds emails by subject and kind" do
      assert_includes Moduler::Email.search_by_query("November"), @email
      assert_includes Moduler::Email.search_by_query("system"), moduler_emails(:welcome)
      assert_not_includes Moduler::Email.search_by_query("system"), @email
    end
  end
end
