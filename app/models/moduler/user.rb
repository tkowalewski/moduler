module Moduler
  class User < ApplicationRecord
    include PgSearch::Model

    has_many :sessions, class_name: "Moduler::Session", foreign_key: "moduler_user_id", dependent: :destroy

    has_secure_password

    normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

    validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { minimum: 8 }, allow_nil: true

    enum :role, { member: 0, administrator: 1 }

    pg_search_scope :search_by_query, against: %i[ email_address ], using: { trigram: { word_similarity: true } }
  end
end
