class QueryFilter < ApplicationFilter
  attribute :query, :string
  attribute :page, :integer

  modifiers << proc do |scope, filter|
    scope.page(filter.page).per(10)
  end

  modifiers << proc do |scope, _filter|
    scope.order(created_at: :desc)
  end

  modifiers << proc do |scope, filter|
    scope.search_by_query(filter.query) if filter.query.present?
  end
end
