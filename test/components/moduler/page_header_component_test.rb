# frozen_string_literal: true

require "test_helper"

class Moduler::PageHeaderComponentTest < ViewComponent::TestCase
  def test_renders_title
    fragment = render_inline(Moduler::PageHeaderComponent.new("Users"))

    assert_equal "Users", fragment.at_css("h1")&.text&.strip
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::PageHeaderComponent.new("Users", description: "Manage users"))

    assert_equal "Manage users", fragment.at_css("p")&.text&.strip
  end

  def test_does_not_render_description_when_not_given
    fragment = render_inline(Moduler::PageHeaderComponent.new("Users"))

    assert_empty fragment.css("p")
  end

  def test_renders_actions
    fragment = render_inline(Moduler::PageHeaderComponent.new("Users")) do |header|
      header.with_action { "First" }
      header.with_action { "Second" }
    end

    assert_includes fragment.text, "First"
    assert_includes fragment.text, "Second"
  end
end
