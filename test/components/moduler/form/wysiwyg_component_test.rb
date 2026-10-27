# frozen_string_literal: true

require "test_helper"

class Moduler::Form::WysiwygComponentTest < ViewComponent::TestCase
  def setup
    @article = Moduler::Article.new
  end

  def test_renders_textarea
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_not_empty fragment.css("textarea[name='article[content]'][id='article_content'][data-wysiwyg-target='markup']")
  end

  def test_renders_value_from_object
    @article.content = "# Hello"

    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_equal "# Hello", fragment.at_css("textarea")&.text&.strip
  end

  def test_renders_rows
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content, rows: 5))

    assert_not_empty fragment.css("textarea[rows='5']")
  end

  def test_renders_preview
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_not_empty fragment.css("[data-controller='wysiwyg'] [data-wysiwyg-target='viewer']")
  end

  def test_renders_toolbar_actions
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    Moduler::Form::WysiwygComponent::ACTIONS.each_key do |action|
      assert_not_empty fragment.css("button[type='button'][data-action='click->wysiwyg##{action}']"), "Expected #{action} button"
    end
  end

  def test_renders_upload_when_object_has_attachments
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_not_empty fragment.css("button[data-action='click->wysiwyg#upload']")
    assert_not_empty fragment.css("[data-wysiwyg-direct-upload-url-value='/rails/active_storage/direct_uploads']")
    assert_not_empty fragment.css("[data-wysiwyg-blob-url-value='/rails/active_storage/blobs/redirect/:signed_id/:filename']")
    assert_not_empty fragment.css("[data-wysiwyg-attachments-field-name-value='article[images][]']")
  end

  def test_does_not_render_upload_when_disabled
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content, attachments: false))

    assert_empty fragment.css("button[data-action='click->wysiwyg#upload']")
    assert_empty fragment.css("[data-wysiwyg-direct-upload-url-value]")
  end

  def test_does_not_render_upload_when_object_has_no_such_attachments
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content, attachments: :photos))

    assert_empty fragment.css("button[data-action='click->wysiwyg#upload']")
  end

  def test_renders_attached_images_as_hidden_fields
    blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture("image.png").open, filename: "image.png", content_type: "image/png")
    @article.images.attach(blob)

    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_not_empty fragment.css("input[type='hidden'][name='article[images][]'][value='#{blob.signed_id}']")
  end

  def test_skips_unpersisted_images_in_hidden_fields
    @article.images.attach(io: file_fixture("image.png").open, filename: "image.png", content_type: "image/png")

    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_empty fragment.css("input[type='hidden'][name='article[images][]']")
  end

  def test_does_not_render_hidden_fields_without_attached_images
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_empty fragment.css("input[type='hidden']")
  end

  def test_renders_label_when_given
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content, label: "Content"))

    assert_equal "Content", fragment.at_css("label[for='article_content']")&.text&.strip
  end

  def test_does_not_render_label_when_not_given
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_empty fragment.css("label")
  end

  def test_renders_description_when_given
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content, description: "Markdown is supported"))

    assert_equal "Markdown is supported", fragment.at_css("p")&.text&.strip
  end

  def test_renders_error_when_field_is_invalid
    @article.errors.add(:content, "can't be blank")

    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_equal "can't be blank", fragment.at_css("div.text-red-500")&.text&.strip
  end

  def test_does_not_render_error_when_field_is_valid
    fragment = render_inline(Moduler::Form::WysiwygComponent.new(form, :content))

    assert_empty fragment.css("div.text-red-500")
  end

  private

  def form
    Moduler::FormBuilder.new(:article, @article, vc_test_controller.view_context, {})
  end
end
