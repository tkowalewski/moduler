module Moduler
  class Session < ApplicationRecord
    belongs_to :user, class_name: "Moduler::User", foreign_key: "moduler_user_id"

    scope :active, -> { where(signed_out_at: nil) }
  end
end
