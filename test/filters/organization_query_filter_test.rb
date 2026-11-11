require "test_helper"

class OrganizationQueryFilterTest < ActiveSupport::TestCase
  setup do
    @acme = moduler_organizations(:acme)
  end

  test "returns records of all organizations without organization_id" do
    _filter, results = OrganizationQueryFilter.new(Moduler::Role.all, {}).call

    assert_equal Moduler::Role.count, results.count
  end

  test "returns records of the given organization" do
    _filter, results = OrganizationQueryFilter.new(Moduler::Role.all, { organization_id: @acme.id }).call

    assert_equal @acme.roles.to_a.sort_by(&:id), results.to_a.sort_by(&:id)
  end

  test "combines organization_id with query" do
    _filter, results = OrganizationQueryFilter.new(Moduler::Role.all, { organization_id: @acme.id, query: "Owner" }).call

    assert_equal [ moduler_roles(:acme_owner) ], results.to_a
  end

  test "orders records newest first" do
    newest = Moduler::Role.create!(organization: @acme, name: "Newest")

    _filter, results = OrganizationQueryFilter.new(Moduler::Role.all, { organization_id: @acme.id }).call

    assert_equal newest, results.first
  end

  test "paginates records by 10" do
    12.times { |i| Moduler::Role.create!(organization: @acme, name: "Role #{i}") }

    _filter, results = OrganizationQueryFilter.new(Moduler::Role.all, { organization_id: @acme.id, page: 2 }).call

    assert_equal @acme.roles.count - 10, results.size
  end

  test "is invalid with a query longer than 100 characters" do
    filter, results = OrganizationQueryFilter.new(Moduler::Role.all, { query: "a" * 101 }).call

    assert_not filter.valid?
    assert_empty results
  end
end
