# frozen_string_literal: true

require "test_helper"

class Moduler::Form::SelectComponentTest < ViewComponent::TestCase
  def setup
    @user = Moduler::User.new
    @choices = [ [ "Member", "member" ], [ "Administrator", "administrator" ] ]
  end

  def test_renders_select_with_choices
    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices))

    assert_not_empty fragment.css("select[name='user[role]'][id='user_role']")
    assert_equal %w[ member administrator ], fragment.css("option").map { |option| option["value"] }
  end

  def test_selects_value_from_object
    @user.role = "administrator"

    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices))

    assert_equal "administrator", fragment.at_css("option[selected]")&.[]("value")
  end

  def test_renders_label_when_given
    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices, label: "Role"))

    assert_equal "Role", fragment.at_css("label[for='user_role']")&.text&.strip
  end

  def test_does_not_render_label_when_not_given
    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices))

    assert_empty fragment.css("label")
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices, description: "Grants access"))

    assert_equal "Grants access", fragment.at_css("p")&.text&.strip
  end

  def test_does_not_render_description_when_not_given
    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices))

    assert_empty fragment.css("p")
  end

  def test_renders_error_when_field_is_invalid
    @user.errors.add(:role, "is not included in the list")

    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices))

    assert_equal "is not included in the list", fragment.at_css("div.text-red-500")&.text&.strip
  end

  def test_does_not_render_error_when_field_is_valid
    @user.errors.add(:email_address, "can't be blank")

    fragment = render_inline(Moduler::Form::SelectComponent.new(form, :role, @choices))

    assert_empty fragment.css("div.text-red-500")
  end

  private

  def form
    Moduler::FormBuilder.new(:user, @user, vc_test_controller.view_context, {})
  end
end
