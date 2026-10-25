# frozen_string_literal: true

require "test_helper"

class Moduler::ListComponentTest < ViewComponent::TestCase
  def test_renders_content_inside_list
    fragment = render_inline(Moduler::ListComponent.new([ 1 ], id: "items")) { "<li>Item</li>".html_safe }

    assert_equal "Item", fragment.at_css("ul#items[role='list'] > li")&.text&.strip
  end

  def test_renders_default_empty_message_when_collection_is_empty
    fragment = render_inline(Moduler::ListComponent.new([], id: "items")) { "<li>Item</li>".html_safe }

    assert_empty fragment.css("ul")
    assert_equal "No results found.", fragment.at_css("p")&.text&.strip
  end

  def test_renders_empty_message_when_given
    fragment = render_inline(Moduler::ListComponent.new([], empty: "No users found."))

    assert_equal "No users found.", fragment.at_css("p")&.text&.strip
  end

  def test_does_not_render_pagination_for_plain_collection
    fragment = render_inline(Moduler::ListComponent.new([ 1 ])) { "<li>Item</li>".html_safe }

    assert_empty fragment.css("nav")
  end
end
