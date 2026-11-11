module Moduler
  module Administration
    class EmailsController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :email ]) }
      before_action :set_email, only: %i[ edit update destroy ]

      def index
        @filter, @emails = QueryFilter.new(Email, permitted_filter_parameters).call
      end

      def new
        @email = Email.new
      end

      def create
        @email = Email.new(permitted_parameters.except(:remove_attachment_ids))

        if @email.save
          redirect_to moduler.administration_emails_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      # New attachments are added to the existing ones, and the attachments
      # marked for removal are removed, once the email is saved.
      def update
        parameters = permitted_parameters
        attachments = parameters.delete(:attachments)
        remove_attachment_ids = parameters.delete(:remove_attachment_ids)

        if @email.update(parameters)
          @email.attachments.attach(attachments) if attachments.present?
          @email.attachments_attachments.where(id: remove_attachment_ids).find_each(&:purge) if remove_attachment_ids.present?

          redirect_to moduler.administration_emails_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @email.destroy!

        redirect_to moduler.administration_emails_path, status: :see_other, notice: t(".notice")
      end

      private

      def set_email
        @email = Email.find(params[:id])
        authorize(@email, policy_class: EmailPolicy)
      end

      def permitted_parameters
        params.expect(email: [ :subject, :sender, :kind, :event, :body, attachments: [], images: [], remove_attachment_ids: [] ]).tap do |parameters|
          parameters[:attachments] = Array(parameters[:attachments]).compact_blank if parameters.key?(:attachments)
        end
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
