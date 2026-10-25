# frozen_string_literal: true

require "test_helper"

class Moduler::ButtonComponentTest < ViewComponent::TestCase
  def test_renders_button_with_text_and_url
    fragment = render_inline(Moduler::ButtonComponent.new("Revoke", "/sessions/1"))

    assert_equal "Revoke", fragment.at_css("form[action='/sessions/1'] button")&.text&.strip
    assert_empty fragment.css("input[name='_method']")
  end

  def test_renders_given_method
    fragment = render_inline(Moduler::ButtonComponent.new("Revoke", "/sessions/1", method: :delete))

    assert_not_empty fragment.css("input[name='_method'][value='delete']")
  end

  def test_renders_confirmation_when_given
    fragment = render_inline(Moduler::ButtonComponent.new("Revoke", "/sessions/1", confirm: "Are you sure?"))

    assert_not_empty fragment.css("form[data-turbo-confirm='Are you sure?']")
  end

  def test_does_not_render_confirmation_when_not_given
    fragment = render_inline(Moduler::ButtonComponent.new("Revoke", "/sessions/1"))

    assert_empty fragment.css("form[data-turbo-confirm]")
  end

  def test_renders_default_size
    fragment = render_inline(Moduler::ButtonComponent.new("Revoke", "/sessions/1"))

    assert_not_empty fragment.css("button.px-3.py-1\\.5")
  end

  def test_renders_small_size
    fragment = render_inline(Moduler::ButtonComponent.new("Revoke", "/sessions/1", size: :sm))

    assert_not_empty fragment.css("button.px-2\\.5.py-1")
    assert_empty fragment.css("button.px-3")
  end
end
