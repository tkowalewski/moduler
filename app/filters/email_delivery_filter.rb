# Filters the users an email can be sent to, see
# Moduler::Administration::Emails::DeliveriesController.
class EmailDeliveryFilter < ApplicationFilter
  PER_PAGE = [ 25, 50, 100 ].freeze

  attribute :query, :string
  attribute :role, :string
  attribute :sent, :string
  attribute :per_page, :integer
  attribute :page, :integer

  validates :query, length: { maximum: 100 }

  modifiers << proc do |scope, filter|
    scope.page(filter.page).per(PER_PAGE.include?(filter.per_page) ? filter.per_page : PER_PAGE.first)
  end

  modifiers << proc do |scope, filter|
    if filter.query.present?
      query = "%#{ActiveRecord::Base.sanitize_sql_like(filter.query)}%"
      scope.where("moduler_users.email_address ILIKE :query OR moduler_users.name ILIKE :query", query: query)
    end
  end

  modifiers << proc do |scope, filter|
    scope.where(role: filter.role) if Moduler::User.roles.key?(filter.role)
  end

  modifiers << proc do |scope, filter|
    case filter.sent
    when "true" then scope.where.not(moduler_user_emails: { sent_at: nil })
    when "false" then scope.where(moduler_user_emails: { sent_at: nil })
    end
  end
end
