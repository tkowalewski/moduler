module Moduler
  class EmailDeliveryJob < ApplicationJob
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(user_email)
      return if user_email.sent?

      EmailMailer.with(email: user_email.email, user: user_email.user).custom.deliver_now
      user_email.touch(:sent_at)
    end
  end
end
