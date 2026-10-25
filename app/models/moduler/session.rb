module Moduler
  class Session < ApplicationRecord
    include PgSearch::Model

    LIFETIME = 30.days

    belongs_to :user, class_name: "Moduler::User", foreign_key: "moduler_user_id"

    scope :active, -> { where(signed_out_at: nil) }

    pg_search_scope :search_by_query, against: %i[ ip_address user_agent ], associated_against: { user: %i[ name email_address ] }, using: { trigram: { word_similarity: true } }

    def active?
      signed_out_at.nil?
    end
  end
end
