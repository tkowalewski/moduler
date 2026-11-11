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

  def test_renders_select_with_prompt_and_choices
    fragment = render_inline(Moduler::FilterComponent.new(OrganizationQueryFilter.new(Moduler::Role, {}), "/roles",
      selects: [ { name: :organization_id, choices: [ [ "Acme", "1" ], [ "Globex", "2" ] ], prompt: "All organizations" } ]))

    assert_equal [ "All organizations", "Acme", "Globex" ], fragment.css("select[name='filter[organization_id]'] option").map { |option| option.text.strip }
    assert_equal "", fragment.at_css("select[name='filter[organization_id]'] option")&.[]("value")
  end

  def test_selects_value_from_filter
    fragment = render_inline(Moduler::FilterComponent.new(OrganizationQueryFilter.new(Moduler::Role, { organization_id: "2" }), "/roles",
      selects: [ { name: :organization_id, choices: [ [ "Acme", "1" ], [ "Globex", "2" ] ], prompt: "All organizations" } ]))

    assert_equal "2", fragment.at_css("select option[selected]")&.[]("value")
  end

  def test_renders_clear_link_when_select_value_present
    fragment = render_inline(Moduler::FilterComponent.new(OrganizationQueryFilter.new(Moduler::Role, { organization_id: "2" }), "/roles",
      selects: [ { name: :organization_id, choices: [ [ "Globex", "2" ] ] } ]))

    assert_equal "Clear", fragment.at_css("a[href='/roles']")&.text&.strip
  end

  def test_does_not_render_select_without_selects
    fragment = render_inline(Moduler::FilterComponent.new(QueryFilter.new(Moduler::User, {}), "/users"))

    assert_empty fragment.css("select")
  end
end
