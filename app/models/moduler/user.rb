module Moduler
  class User < ApplicationRecord
    include PgSearch::Model

    has_many :sessions, class_name: "Moduler::Session", foreign_key: "moduler_user_id", dependent: :destroy
    has_many :user_documents, class_name: "Moduler::UserDocument", foreign_key: "moduler_user_id", dependent: :destroy
    has_many :documents, class_name: "Moduler::Document", through: :user_documents
    has_many :memberships, class_name: "Moduler::Membership", foreign_key: "moduler_user_id", dependent: :destroy
    has_many :organizations, class_name: "Moduler::Organization", through: :memberships
    has_many :user_emails, class_name: "Moduler::UserEmail", foreign_key: "moduler_user_id", dependent: :destroy
    has_many :emails, class_name: "Moduler::Email", through: :user_emails
    has_many :sent_emails, class_name: "Moduler::SentEmail", foreign_key: "moduler_user_id", dependent: :nullify

    has_secure_password

    normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }
    normalizes :name, with: ->(name) { name.strip.presence }

    validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { minimum: 8 }, allow_nil: true
    validates :name, length: { maximum: 100 }

    enum :role, { member: 0, administrator: 1 }
    enum :status, { waitlisted: 0, active: 1, inactive: 2 }, default: :active

    pg_search_scope :search_by_query, against: %i[ email_address name ], using: { trigram: { word_similarity: true } }

    # The name, or the email address when the user has no name.
    def display_name
      name.presence || email_address
    end

    # Documents the user has not accepted yet.
    def pending_documents
      Moduler::Document.where.not(id: user_documents.select(:moduler_document_id))
    end
  end
end
