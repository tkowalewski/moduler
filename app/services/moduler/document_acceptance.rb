module Moduler
  # Accepts the documents a user has not accepted yet. Every pending document
  # must be among the accepted ids; otherwise nothing is accepted. Ids of
  # unknown or already accepted documents are ignored.
  class DocumentAcceptance
    include ActiveModel::Validations

    attr_reader :user, :document_ids

    validate :all_pending_documents_accepted

    def initialize(user, document_ids = [])
      @user = user
      @document_ids = Array(document_ids).compact_blank.map(&:to_i)
    end

    def pending_documents
      @pending_documents ||= user.pending_documents.with_attached_file.order(:created_at).to_a
    end

    def accepted?(document)
      document_ids.include?(document.id)
    end

    def call
      return false if invalid?

      UserDocument.insert_all(rows, unique_by: %i[ moduler_document_id moduler_user_id ])

      true
    end

    private

    def all_pending_documents_accepted
      errors.add(:base, :not_all_accepted) if pending_documents.any? { |document| !accepted?(document) }
    end

    def rows
      pending_documents.map { |document| { moduler_user_id: user.id, moduler_document_id: document.id } }
    end
  end
end
