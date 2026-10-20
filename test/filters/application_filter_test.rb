require "test_helper"

class ApplicationFilterTest < ActiveSupport::TestCase
  class EmailFilter < ApplicationFilter
    attribute :email_address, :string

    validates :email_address, length: { minimum: 3 }, allow_blank: true

    modifiers << ->(scope, filter) do
      scope.where("email_address LIKE ?", "%#{filter.email_address}%") if filter.email_address.present?
    end
  end

  setup do
    @scope = Moduler::User.all
  end

  test "modifiers are stored per class" do
    assert_equal 1, EmailFilter.modifiers.size
    assert_empty ApplicationFilter.modifiers
  end

  test "call returns the filter and the results" do
    filter, results = EmailFilter.new(@scope, {}).call

    assert_kind_of EmailFilter, filter
    assert_kind_of ActiveRecord::Relation, results
  end

  test "returns unfiltered scope when no parameters are given" do
    filter, results = EmailFilter.new(@scope, {}).call

    assert_not filter.changed?
    assert_empty filter.errors
    assert_equal @scope.to_a, results.to_a
  end

  test "returns empty page when no parameters are given and allow_empty is set" do
    _filter, results = EmailFilter.new(@scope, {}, allow_empty: true).call

    assert_empty results
    assert_equal 1, results.current_page
  end

  test "applies modifiers when parameters are given" do
    filter, results = EmailFilter.new(@scope, { email_address: "domain" }).call

    assert filter.changed?
    assert_equal [ moduler_users(:default) ], results.to_a
  end

  test "applies modifiers when parameters are given and allow_empty is set" do
    _filter, results = EmailFilter.new(@scope, { email_address: "domain" }, allow_empty: true).call

    assert_equal [ moduler_users(:default) ], results.to_a
  end

  test "returns no records when nothing matches" do
    _filter, results = EmailFilter.new(@scope, { email_address: "missing" }).call

    assert_empty results
  end

  test "keeps current scope when modifier returns nil" do
    _filter, results = EmailFilter.new(@scope, { email_address: "" }).call

    assert_equal @scope.to_a, results.to_a
  end

  test "returns empty page and errors when parameters are invalid" do
    filter, results = EmailFilter.new(@scope, { email_address: "ab" }).call

    assert filter.errors[:email_address].any?
    assert_empty results
    assert_equal 1, results.current_page
  end
end
