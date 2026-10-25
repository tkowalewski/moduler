# frozen_string_literal: true

require "test_helper"

class Moduler::ListItemComponentTest < ViewComponent::TestCase
  def test_renders_title_and_id
    fragment = render_inline(Moduler::ListItemComponent.new("john@example.com", id: "user_1"))

    assert_equal "john@example.com", fragment.at_css("li#user_1 p")&.text&.strip
  end

  def test_renders_badges
    fragment = render_inline(Moduler::ListItemComponent.new("john@example.com")) do |item|
      item.with_badge("Administrator", variant: :success)
      item.with_badge("Active")
    end

    assert_equal %w[ Administrator Active ], fragment.css("span").map { |badge| badge.text.strip }
  end

  def test_renders_meta_when_given
    fragment = render_inline(Moduler::ListItemComponent.new("john@example.com")) do |item|
      item.with_meta { "Created 2 days ago" }
    end

    assert_equal "Created 2 days ago", fragment.at_css("p.text-xs")&.text&.strip
  end

  def test_does_not_render_meta_when_not_given
    fragment = render_inline(Moduler::ListItemComponent.new("john@example.com"))

    assert_empty fragment.css("p.text-xs")
  end

  def test_renders_actions_when_given
    fragment = render_inline(Moduler::ListItemComponent.new("john@example.com")) do |item|
      item.with_action { "Edit" }
    end

    assert_equal "Edit", fragment.at_css("li > div.shrink-0")&.text&.strip
  end

  def test_does_not_render_actions_container_when_not_given
    fragment = render_inline(Moduler::ListItemComponent.new("john@example.com"))

    assert_empty fragment.css("li > div.shrink-0")
  end
end
