module Moduler
  class DocumentAcceptancesController < ApplicationController
    skip_document_acceptance

    before_action :set_document_acceptance

    def new; end

    def create
      if @document_acceptance.call
        redirect_to moduler.root_path, notice: t(".notice")
      else
        flash.now[:alert] = @document_acceptance.errors.full_messages.to_sentence

        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_document_acceptance
      @document_acceptance = DocumentAcceptance.new(Current.user, params.dig(:document_acceptance, :document_ids))
    end
  end
end
