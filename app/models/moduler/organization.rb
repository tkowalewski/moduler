module Moduler
  class Organization < ApplicationRecord
    include PgSearch::Model

    has_many :memberships, class_name: "Moduler::Membership", foreign_key: "moduler_organization_id", dependent: :delete_all
    has_many :users, class_name: "Moduler::User", through: :memberships
    has_many :roles, class_name: "Moduler::Role", foreign_key: "moduler_organization_id", dependent: :delete_all

    validates :name, presence: true, uniqueness: true

    pg_search_scope :search_by_query, against: %i[ name ], using: { trigram: { word_similarity: true } }
  end
end
