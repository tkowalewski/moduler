module Moduler
  class Membership < ApplicationRecord
    include PgSearch::Model

    belongs_to :user, class_name: "Moduler::User", foreign_key: "moduler_user_id"
    belongs_to :organization, class_name: "Moduler::Organization", foreign_key: "moduler_organization_id"
    belongs_to :role, class_name: "Moduler::Role", foreign_key: "moduler_role_id"

    delegate :permission?, to: :role

    validates :user, uniqueness: { scope: :moduler_organization_id }
    validate :user_must_be_member
    validate :role_must_belong_to_organization

    pg_search_scope :search_by_query, associated_against: { user: :email_address }, using: { trigram: { word_similarity: true } }

    # Sidebar resources from config/moduler.yml the member may see: those
    # without a permission and those whose permission the role grants, in
    # the configured order.
    def visible_resources(resources = Moduler.configuration.resources)
      resources.select { |resource| resource.permission.nil? || permission?(resource.permission) }
    end

    # The page the member lands on when entering the organization: the first
    # visible resource, or +nil+ when the member may see none.
    def home_resource(resources = Moduler.configuration.resources)
      visible_resources(resources).first
    end

    private

    def user_must_be_member
      errors.add(:user, :not_member) if user && !user.member?
    end

    def role_must_belong_to_organization
      errors.add(:role, :inclusion) if role && role.moduler_organization_id != moduler_organization_id
    end
  end
end
