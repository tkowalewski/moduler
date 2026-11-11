module Moduler
  # An email queued for a user; sent_at is set once it has been delivered.
  class UserEmail < ApplicationRecord
    belongs_to :user, class_name: "Moduler::User", foreign_key: "moduler_user_id"
    belongs_to :email, class_name: "Moduler::Email", foreign_key: "moduler_email_id"

    validates :user, uniqueness: { scope: :moduler_email_id }

    scope :sent, -> { where.not(sent_at: nil) }

    def sent?
      sent_at.present?
    end
  end
end
