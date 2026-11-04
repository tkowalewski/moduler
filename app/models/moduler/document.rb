module Moduler
  class Document < ApplicationRecord
    include PgSearch::Model

    KINDS = %w[ privacy_policy terms_and_conditions data_processing_agreement ].freeze

    has_many :user_documents, class_name: "Moduler::UserDocument", foreign_key: "moduler_document_id", dependent: :delete_all

    has_one_attached :file

    validates :name, presence: true
    validates :kind, presence: true, inclusion: { in: KINDS }
    validates :file, presence: true, content_type: %w[ application/pdf ], size: { less_than: 10.megabytes }

    pg_search_scope :search_by_query, against: %i[ name kind ], using: { trigram: { word_similarity: true } }
  end
end
