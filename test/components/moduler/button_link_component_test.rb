# frozen_string_literal: true

require "test_helper"

class Moduler::ButtonLinkComponentTest < ViewComponent::TestCase
  def test_renders_link_with_text_and_url
    fragment = render_inline(Moduler::ButtonLinkComponent.new("Create", "/users/new"))

    assert_equal "Create", fragment.at_css("a[href='/users/new']")&.text&.strip
  end

  def test_renders_default_size
    fragment = render_inline(Moduler::ButtonLinkComponent.new("Create", "/users/new"))

    assert_not_empty fragment.css("a.px-3.py-2")
  end

  def test_renders_small_size
    fragment = render_inline(Moduler::ButtonLinkComponent.new("Edit", "/users/1/edit", size: :sm))

    assert_not_empty fragment.css("a.px-2\\.5.py-1")
    assert_empty fragment.css("a.py-2")
  end
end
