module Moduler
  # Something done in the application, kept for security and compliance: who did what, to
  # what, in which organization, from where and when. Events are recorded with
  # Moduler::Audit.record and never changed or removed by the application.
  class AuditEvent < ApplicationRecord
    include PgSearch::Model

    belongs_to :user, class_name: "Moduler::User", foreign_key: "moduler_user_id", optional: true
    belongs_to :organization, class_name: "Moduler::Organization", foreign_key: "moduler_organization_id", optional: true
    belongs_to :subject, polymorphic: true, optional: true

    validates :action, presence: true

    pg_search_scope :search_by_query, against: %i[ action ip_address ], associated_against: { user: %i[ email_address ] },
      using: { trigram: { word_similarity: true } }

    def readonly?
      persisted?
    end
  end
end
