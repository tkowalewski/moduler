module Moduler
  # A copy of every email delivered by the engine's mailers, recorded by
  # Moduler::ApplicationMailer and shown in the recipient's profile.
  class SentEmail < ApplicationRecord
    belongs_to :user, class_name: "Moduler::User", foreign_key: "moduler_user_id", optional: true

    has_many_attached :attachments

    validates :to_address, presence: true
    validates :subject, presence: true
    validates :body, presence: true
  end
end
