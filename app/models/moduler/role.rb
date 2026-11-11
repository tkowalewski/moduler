module Moduler
  class Role < ApplicationRecord
    include PgSearch::Model

    belongs_to :organization, class_name: "Moduler::Organization", foreign_key: "moduler_organization_id"
    has_many :memberships, class_name: "Moduler::Membership", foreign_key: "moduler_role_id", dependent: :restrict_with_error

    normalizes :permissions, with: ->(permissions) { Array(permissions).map(&:to_s).compact_blank.uniq }

    validates :name, presence: true, uniqueness: { scope: :moduler_organization_id }
    validate :permissions_must_be_configured

    pg_search_scope :search_by_query, against: %i[ name ], using: { trigram: { word_similarity: true } }

    def permission?(permission)
      permissions.include?(permission.to_s)
    end

    private

    def permissions_must_be_configured
      unknown = permissions - Moduler.configuration.permissions
      errors.add(:permissions, :inclusion, value: unknown.join(", ")) if unknown.any?
    end
  end
end
