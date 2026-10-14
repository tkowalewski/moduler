# frozen_string_literal: true

require "test_helper"

class Moduler::Form::TextComponentTest < ViewComponent::TestCase
  def setup
    @user = Moduler::User.new
  end

  def test_renders_text_field
    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address))

    assert_not_empty fragment.css("input[type='text'][name='user[email_address]'][id='user_email_address']")
  end

  def test_renders_value_from_object
    @user.email_address = "john@example.com"

    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address))

    assert_not_empty fragment.css("input[type='text'][value='john@example.com']")
  end

  def test_renders_placeholder
    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address, placeholder: "Your email"))

    assert_not_empty fragment.css("input[type='text'][placeholder='Your email']")
  end

  def test_renders_label_when_given
    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address, label: "Email address"))

    assert_equal "Email address", fragment.at_css("label[for='user_email_address']")&.text&.strip
  end

  def test_does_not_render_label_when_not_given
    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address))

    assert_empty fragment.css("label")
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address, description: "We never share your email"))

    assert_equal "We never share your email", fragment.at_css("p")&.text&.strip
  end

  def test_does_not_render_description_when_not_given
    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address))

    assert_empty fragment.css("p")
  end

  def test_renders_error_when_field_is_invalid
    @user.errors.add(:email_address, "can't be blank")

    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address))

    assert_equal "can't be blank", fragment.at_css("div.text-red-500")&.text&.strip
  end

  def test_does_not_render_error_when_field_is_valid
    @user.errors.add(:password, "can't be blank")

    fragment = render_inline(Moduler::Form::TextComponent.new(form, :email_address))

    assert_empty fragment.css("div.text-red-500")
  end

  private

  def form
    Moduler::FormBuilder.new(:user, @user, vc_test_controller.view_context, {})
  end
end
