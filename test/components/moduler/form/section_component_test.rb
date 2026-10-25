# frozen_string_literal: true

require "test_helper"

class Moduler::Form::SectionComponentTest < ViewComponent::TestCase
  def test_renders_title_and_content
    fragment = render_inline(Moduler::Form::SectionComponent.new("User data")) { "Fields" }

    assert_equal "User data", fragment.at_css("p")&.text&.strip
    assert_includes fragment.at_css("div")&.text, "Fields"
  end

  def test_does_not_render_divider_by_default
    fragment = render_inline(Moduler::Form::SectionComponent.new("User data")) { "Fields" }

    assert_empty fragment.css("div.border-t")
  end

  def test_renders_divider_when_given
    fragment = render_inline(Moduler::Form::SectionComponent.new("Password", divider: true)) { "Fields" }

    assert_not_empty fragment.css("div.border-t.pt-6")
  end
end
