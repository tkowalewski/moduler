module Moduler
  class EmailMailer < ApplicationMailer
    def custom
      @email = params[:email]
      @user = params[:user]

      @email.attachments.each do |attachment|
        attachments[attachment.filename.to_s] = attachment.download
      end

      mail(to: @user.email_address, subject: @email.subject, from: @email.sender.presence || self.class.default[:from])
    end
  end
end
