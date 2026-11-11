module Moduler
  module Profile
    # Emails delivered to the signed-in user.
    class SentEmailsController < ApplicationController
      skip_document_acceptance
      allow_administrator_access

      def index
        @sent_emails = Current.user.sent_emails.with_attached_attachments.order(created_at: :desc).page(params[:page]).per(20)
      end

      # The email as it was delivered.
      def show
        render html: Current.user.sent_emails.find(params[:id]).body.html_safe, layout: false
      end
    end
  end
end
