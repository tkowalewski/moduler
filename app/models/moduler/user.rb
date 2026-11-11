module Moduler
  class User < ApplicationRecord
    include PgSearch::Model

    has_many :sessions, class_name: "Moduler::Session", foreign_key: "moduler_user_id", dependent: :destroy
    has_many :user_documents, class_name: "Moduler::UserDocument", foreign_key: "moduler_user_id", dependent: :destroy
    has_many :documents, class_name: "Moduler::Document", through: :user_documents
    has_many :memberships, class_name: "Moduler::Membership", foreign_key: "moduler_user_id", dependent: :destroy
    has_many :organizations, class_name: "Moduler::Organization", through: :memberships

    has_secure_password

    normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

    validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { minimum: 8 }, allow_nil: true

    enum :role, { member: 0, administrator: 1 }
    enum :status, { waitlisted: 0, active: 1, inactive: 2 }, default: :active

    pg_search_scope :search_by_query, against: %i[ email_address ], using: { trigram: { word_similarity: true } }

    # Documents the user has not accepted yet.
    def pending_documents
      Moduler::Document.where.not(id: user_documents.select(:moduler_document_id))
    end
  end
end
