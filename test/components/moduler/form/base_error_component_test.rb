# frozen_string_literal: true

require "test_helper"

class Moduler::Form::BaseErrorComponentTest < ViewComponent::TestCase
  def setup
    @user = Moduler::User.new
  end

  def test_renders_base_error
    @user.errors.add(:base, "Invalid email address or password")

    fragment = render_inline(Moduler::Form::BaseErrorComponent.new(form))

    assert_equal "Invalid email address or password", fragment.at_css("div.text-red-600")&.text&.strip
  end

  def test_renders_only_first_base_error
    @user.errors.add(:base, "First error")
    @user.errors.add(:base, "Second error")

    fragment = render_inline(Moduler::Form::BaseErrorComponent.new(form))

    assert_equal 1, fragment.css("div").size
    assert_equal "First error", fragment.at_css("div")&.text&.strip
  end

  def test_does_not_render_when_no_base_error
    fragment = render_inline(Moduler::Form::BaseErrorComponent.new(form))

    assert_empty fragment.css("div")
  end

  def test_does_not_render_field_errors
    @user.errors.add(:email_address, "can't be blank")

    fragment = render_inline(Moduler::Form::BaseErrorComponent.new(form))

    assert_empty fragment.css("div")
  end

  private

  def form
    Moduler::FormBuilder.new(:user, @user, vc_test_controller.view_context, {})
  end
end
