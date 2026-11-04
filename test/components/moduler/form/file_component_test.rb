# frozen_string_literal: true

require "test_helper"

class Moduler::Form::FileComponentTest < ViewComponent::TestCase
  def setup
    @document = Moduler::Document.new
  end

  def test_renders_file_field
    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file))

    assert_not_empty fragment.css("input[type='file'][name='document[file]'][id='document_file']")
  end

  def test_renders_accept_when_given
    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file, accept: "application/pdf"))

    assert_equal "application/pdf", fragment.at_css("input[type='file']")&.[]("accept")
  end

  def test_does_not_render_accept_when_not_given
    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file))

    assert_nil fragment.at_css("input[type='file']")&.[]("accept")
  end

  def test_renders_label_when_given
    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file, label: "File"))

    assert_equal "File", fragment.at_css("label[for='document_file']")&.text&.strip
  end

  def test_does_not_render_label_when_not_given
    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file))

    assert_empty fragment.css("label")
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file, description: "PDF only"))

    assert_equal "PDF only", fragment.at_css("p")&.text&.strip
  end

  def test_does_not_render_description_when_not_given
    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file))

    assert_empty fragment.css("p")
  end

  def test_renders_error_when_field_is_invalid
    @document.errors.add(:file, "can't be blank")

    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file))

    assert_equal "can't be blank", fragment.at_css("div.text-red-500")&.text&.strip
  end

  def test_does_not_render_error_when_field_is_valid
    @document.errors.add(:name, "can't be blank")

    fragment = render_inline(Moduler::Form::FileComponent.new(form, :file))

    assert_empty fragment.css("div.text-red-500")
  end

  private

  def form
    Moduler::FormBuilder.new(:document, @document, vc_test_controller.view_context, {})
  end
end
