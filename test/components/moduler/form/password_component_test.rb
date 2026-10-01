# frozen_string_literal: true

require "test_helper"

class Moduler::Form::PasswordComponentTest < ViewComponent::TestCase
  def setup
    @user = Moduler::User.new
  end

  def test_renders_password_field
    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password))

    assert_not_empty fragment.css("input[type='password'][name='user[password]'][id='user_password']")
  end

  def test_renders_placeholder
    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password, placeholder: "Your password"))

    assert_not_empty fragment.css("input[type='password'][placeholder='Your password']")
  end

  def test_renders_label_when_given
    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password, label: "Password"))

    assert_equal "Password", fragment.at_css("label")&.text&.strip
  end

  def test_does_not_render_label_when_not_given
    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password))

    assert_empty fragment.css("label")
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password, description: "At least 8 characters"))

    assert_equal "At least 8 characters", fragment.at_css("p")&.text&.strip
  end

  def test_does_not_render_description_when_not_given
    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password))

    assert_empty fragment.css("p")
  end

  def test_renders_error_when_field_is_invalid
    @user.errors.add(:password, "can't be blank")

    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password))

    assert_equal "can't be blank", fragment.at_css("div.text-red-500")&.text&.strip
  end

  def test_does_not_render_error_when_field_is_valid
    @user.errors.add(:email_address, "can't be blank")

    fragment = render_inline(Moduler::Form::PasswordComponent.new(form, :password))

    assert_empty fragment.css("div.text-red-500")
  end

  private

  def form
    Moduler::FormBuilder.new(:user, @user, vc_test_controller.view_context, {})
  end
end
