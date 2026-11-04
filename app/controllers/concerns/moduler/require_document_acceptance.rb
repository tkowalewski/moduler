module Moduler
  # Blocks the panel for signed-in users until they accept every document.
  # Controllers that must stay available meanwhile (the profile, signing out,
  # public pages) opt out with +skip_document_acceptance+.
  module RequireDocumentAcceptance
    extend ActiveSupport::Concern

    included do
      before_action :require_document_acceptance
      helper_method :document_acceptance_required?
    end

    class_methods do
      def skip_document_acceptance(**options)
        skip_before_action :require_document_acceptance, **options
      end
    end

    private

    def document_acceptance_required?
      return @document_acceptance_required if defined?(@document_acceptance_required)

      @document_acceptance_required = Current.user.present? && Current.user.pending_documents.exists?
    end

    def require_document_acceptance
      redirect_to moduler.new_document_acceptance_path if document_acceptance_required?
    end
  end
end
