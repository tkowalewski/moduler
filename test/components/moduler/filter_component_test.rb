# frozen_string_literal: true

require "test_helper"

class Moduler::FilterComponentTest < ViewComponent::TestCase
  def test_renders_get_form_with_query_field
    fragment = render_inline(Moduler::FilterComponent.new(QueryFilter.new(Moduler::User, {}), "/users"))

    assert_not_empty fragment.css("form[action='/users'][method='get'] input[name='filter[query]']")
    assert_not_empty fragment.css("input[type='submit'][value='Filter']")
  end

  def test_renders_default_placeholder
    fragment = render_inline(Moduler::FilterComponent.new(QueryFilter.new(Moduler::User, {}), "/users"))

    assert_not_empty fragment.css("input[name='filter[query]'][placeholder='Search...']")
  end

  def test_renders_placeholder_when_given
    fragment = render_inline(Moduler::FilterComponent.new(QueryFilter.new(Moduler::User, {}), "/users", placeholder: "Email address"))

    assert_not_empty fragment.css("input[name='filter[query]'][placeholder='Email address']")
  end

  def test_renders_query_value_and_clear_link_when_query_present
    fragment = render_inline(Moduler::FilterComponent.new(QueryFilter.new(Moduler::User, { query: "john" }), "/users"))

    assert_not_empty fragment.css("input[name='filter[query]'][value='john']")
    assert_equal "Clear", fragment.at_css("a[href='/users']")&.text&.strip
  end

  def test_does_not_render_clear_link_without_query
    fragment = render_inline(Moduler::FilterComponent.new(QueryFilter.new(Moduler::User, {}), "/users"))

    assert_empty fragment.css("a")
  end
end
