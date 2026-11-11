class OrganizationQueryFilter < ApplicationFilter
  attribute :query, :string
  attribute :organization_id, :string
  attribute :page, :integer

  validates :query, length: { maximum: 100 }

  modifiers << proc do |scope, filter|
    scope.page(filter.page).per(10)
  end

  modifiers << proc do |scope, _filter|
    scope.order(created_at: :desc)
  end

  modifiers << proc do |scope, filter|
    scope.search_by_query(filter.query) if filter.query.present?
  end

  modifiers << proc do |scope, filter|
    scope.where(moduler_organization_id: filter.organization_id) if filter.organization_id.present?
  end
end
