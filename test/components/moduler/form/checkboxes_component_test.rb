# frozen_string_literal: true

require "test_helper"

class Moduler::Form::CheckboxesComponentTest < ViewComponent::TestCase
  def setup
    @role = Moduler::Role.new
    @choices = [ [ "Read tasks", "tasks.read" ], [ "Write tasks", "tasks.write" ] ]
  end

  def test_renders_checkbox_for_each_choice
    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices))

    assert_equal %w[ tasks.read tasks.write ], fragment.css("input[type='checkbox'][name='role[permissions][]']").map { |input| input["value"] }
  end

  def test_renders_hidden_field_so_all_choices_can_be_unchecked
    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices))

    assert_not_empty fragment.css("input[type='hidden'][name='role[permissions][]'][value='']")
  end

  def test_renders_label_for_each_choice
    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices))

    assert_equal "Read tasks", fragment.at_css("label[for='role_permissions_tasks_read']")&.text&.strip
  end

  def test_checks_values_from_object
    @role.permissions = %w[ tasks.write ]

    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices))

    assert_equal %w[ tasks.write ], fragment.css("input[type='checkbox'][checked]").map { |input| input["value"] }
  end

  def test_renders_legend_when_label_given
    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices, label: "Permissions"))

    assert_equal "Permissions", fragment.at_css("fieldset legend")&.text&.strip
  end

  def test_does_not_render_legend_when_label_not_given
    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices))

    assert_empty fragment.css("legend")
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices, description: "Pick some"))

    assert_equal "Pick some", fragment.at_css("p")&.text&.strip
  end

  def test_renders_error_when_field_is_invalid
    @role.errors.add(:permissions, "is not included in the list")

    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices))

    assert_equal "is not included in the list", fragment.at_css("div.text-red-500")&.text&.strip
  end

  def test_does_not_render_error_when_field_is_valid
    @role.errors.add(:name, "can't be blank")

    fragment = render_inline(Moduler::Form::CheckboxesComponent.new(form, :permissions, @choices))

    assert_empty fragment.css("div.text-red-500")
  end

  private

  def form
    Moduler::FormBuilder.new(:role, @role, vc_test_controller.view_context, {})
  end
end
