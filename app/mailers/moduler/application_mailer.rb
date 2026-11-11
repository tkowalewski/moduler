module Moduler
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "moduler/mailer"

    after_deliver :record_sent_email

    private

    # Keeps a copy of the delivered email, shown in the recipient's profile.
    # A failure to record it does not fail the delivery.
    def record_sent_email
      to_address = message.to&.first
      return if to_address.blank?

      sent_email = SentEmail.new(
        user: User.find_by(email_address: to_address.downcase),
        to_address: to_address,
        subject: message.subject,
        body: (message.html_part || message).body.decoded
      )

      message.attachments.each do |attachment|
        sent_email.attachments.attach(io: StringIO.new(attachment.body.decoded), filename: attachment.filename, content_type: attachment.mime_type)
      end

      sent_email.save!
    rescue StandardError => error
      Rails.error.report(error, handled: true)
    end
  end
end
