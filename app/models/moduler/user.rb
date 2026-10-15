module Moduler
  class User < ApplicationRecord
    has_many :sessions, class_name: "Moduler::Session", foreign_key: "moduler_user_id", dependent: :destroy

    has_secure_password

    validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    enum :role, { member: 0, administrator: 1 }
  end
end
