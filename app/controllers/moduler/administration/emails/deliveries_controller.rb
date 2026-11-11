module Moduler
  module Administration
    module Emails
      # Sending an email to users chosen from a filterable list.
      class DeliveriesController < ApplicationController
        before_action :set_email

        def new
          @filter, @users = EmailDeliveryFilter.new(candidates, permitted_filter_parameters).call
        end

        def create
          queued = @email.deliver_to(User.where(id: Array(params[:user_ids])))

          redirect_to moduler.new_administration_email_delivery_path(@email), notice: t(".notice", count: queued)
        end

        private

        def set_email
          @email = Email.find(params[:email_id])
          authorize(@email, :deliver?, policy_class: EmailPolicy)
        end

        # Users with the id and sent_at of their queued email, if any.
        def candidates
          User
            .joins(User.sanitize_sql_array([
              "LEFT JOIN moduler_user_emails ON moduler_user_emails.moduler_user_id = moduler_users.id AND moduler_user_emails.moduler_email_id = ?",
              @email.id
            ]))
            .select("moduler_users.*", "moduler_user_emails.id AS user_email_id", "moduler_user_emails.sent_at AS user_email_sent_at")
            .order(:email_address)
        end

        def permitted_filter_parameters
          (params.permit(filter: %i[ query role sent per_page ])[:filter] || {}).merge(params.permit(:page))
        end
      end
    end
  end
end
