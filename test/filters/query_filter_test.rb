require "test_helper"

class QueryFilterTest < ActiveSupport::TestCase
  setup do
    @scope = Moduler::User.all
    @default = moduler_users(:default)
    @administrator = moduler_users(:administrator)
  end

  test "returns all records ordered by created_at descending when no parameters are given" do
    @default.update_column(:created_at, 2.days.ago)
    @administrator.update_column(:created_at, 1.day.ago)

    filter, results = QueryFilter.new(@scope, {}).call

    assert_not filter.changed?
    assert_equal [ @administrator, @default ], results.to_a
  end

  test "returns only records matching the query" do
    filter, results = QueryFilter.new(@scope, { query: "test@" }).call

    assert filter.changed?
    assert_equal [ @default ], results.to_a
  end

  test "returns no records when the query matches nothing" do
    _filter, results = QueryFilter.new(@scope, { query: "nobody@example.com" }).call

    assert_empty results.to_a
  end

  test "ignores a blank query" do
    _filter, results = QueryFilter.new(@scope, { query: "" }).call

    assert_equal 2, results.count
  end

  test "returns no records when the query is too long" do
    filter, results = QueryFilter.new(@scope, { query: "a" * 101 }).call

    assert filter.errors[:query].any?
    assert_empty results.to_a
  end

  test "paginates ten records per page" do
    Moduler::User.insert_all(
      9.times.map { |i| { email_address: "bulk#{i}@example.com", password_digest: "x" * 60 } }
    )

    _filter, results = QueryFilter.new(@scope, {}).call

    assert_equal 11, results.total_count
    assert_equal 2, results.total_pages
    assert_equal 1, results.current_page

    _filter, second_page = QueryFilter.new(@scope, { page: 2 }).call

    assert_equal 2, second_page.current_page
    assert_equal 1, second_page.count
  end
end
