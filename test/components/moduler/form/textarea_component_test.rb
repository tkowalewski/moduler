# frozen_string_literal: true

require "test_helper"

class Moduler::Form::TextareaComponentTest < ViewComponent::TestCase
  def setup
    @article = Moduler::Article.new
  end

  def test_renders_textarea
    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description))

    assert_not_empty fragment.css("textarea[name='article[description]'][id='article_description']")
  end

  def test_renders_value_from_object
    @article.description = "A short summary"

    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description))

    assert_equal "A short summary", fragment.at_css("textarea")&.text&.strip
  end

  def test_renders_label_when_given
    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description, label: "Description"))

    assert_equal "Description", fragment.at_css("label[for='article_description']")&.text&.strip
  end

  def test_does_not_render_label_when_not_given
    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description))

    assert_empty fragment.css("label")
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description, description: "Shown in search results"))

    assert_equal "Shown in search results", fragment.at_css("p")&.text&.strip
  end

  def test_does_not_render_description_when_not_given
    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description))

    assert_empty fragment.css("p")
  end

  def test_renders_error_when_field_is_invalid
    @article.errors.add(:description, "can't be blank")

    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description))

    assert_equal "can't be blank", fragment.at_css("div.text-red-500")&.text&.strip
  end

  def test_does_not_render_error_when_field_is_valid
    @article.errors.add(:title, "can't be blank")

    fragment = render_inline(Moduler::Form::TextareaComponent.new(form, :description))

    assert_empty fragment.css("div.text-red-500")
  end

  private

  def form
    Moduler::FormBuilder.new(:article, @article, vc_test_controller.view_context, {})
  end
end
