module Moduler
  module Administration
    class DocumentsController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :document ]) }
      before_action :set_document, only: %i[ edit update ]

      def index
        @filter, @documents = QueryFilter.new(Document.with_attached_file, permitted_filter_parameters).call
      end

      def new
        @document = Document.new
      end

      def create
        @document = Document.new(permitted_parameters)

        if @document.save
          redirect_to moduler.administration_documents_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @document.update(permitted_update_parameters)
          redirect_to moduler.administration_documents_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def set_document
        @document = Document.find(params[:id])
        authorize(@document, policy_class: DocumentPolicy)
      end

      def permitted_parameters
        params.expect(document: %i[ name kind file ])
      end

      # The file is set only when the document is created and cannot be replaced.
      def permitted_update_parameters
        params.expect(document: %i[ name kind ])
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
