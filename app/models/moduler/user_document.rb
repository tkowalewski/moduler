module Moduler
  class UserDocument < ApplicationRecord
    belongs_to :user, class_name: "Moduler::User", foreign_key: "moduler_user_id"
    belongs_to :document, class_name: "Moduler::Document", foreign_key: "moduler_document_id"

    validates :user, presence: true, uniqueness: { scope: :moduler_document_id }
  end
end
