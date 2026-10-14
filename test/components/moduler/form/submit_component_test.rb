# frozen_string_literal: true

require "test_helper"

class Moduler::Form::SubmitComponentTest < ViewComponent::TestCase
  def setup
    @user = Moduler::User.new
  end

  def test_renders_submit_button
    fragment = render_inline(Moduler::Form::SubmitComponent.new(form))

    assert_not_empty fragment.css("input[type='submit'][name='commit']")
  end

  def test_renders_text_when_given
    fragment = render_inline(Moduler::Form::SubmitComponent.new(form, text: "Sign in"))

    assert_not_empty fragment.css("input[type='submit'][value='Sign in']")
  end

  def test_renders_default_text_for_new_record_when_not_given
    fragment = render_inline(Moduler::Form::SubmitComponent.new(form))

    assert_not_empty fragment.css("input[type='submit'][value='Create User']")
  end

  def test_renders_default_text_for_persisted_record_when_not_given
    @user.define_singleton_method(:persisted?) { true }

    fragment = render_inline(Moduler::Form::SubmitComponent.new(form))

    assert_not_empty fragment.css("input[type='submit'][value='Update User']")
  end

  private

  def form
    Moduler::FormBuilder.new(:user, @user, vc_test_controller.view_context, {})
  end
end
