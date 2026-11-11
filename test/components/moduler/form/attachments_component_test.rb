# frozen_string_literal: true

require "test_helper"

class Moduler::Form::AttachmentsComponentTest < ViewComponent::TestCase
  def setup
    @email = moduler_emails(:newsletter)
  end

  def test_renders_a_template_row_with_a_single_file_field
    fragment = render_inline(Moduler::Form::AttachmentsComponent.new(form, :attachments))

    assert_not_nil fragment.at_css("template[data-attachments-target='template'] li input[type='file'][name='email[attachments][]']:not([multiple])")
    assert_not_nil fragment.at_css("template li button[data-action='attachments#remove']")
    assert_equal "Add attachment", fragment.at_css("button[data-action='attachments#add']")&.text&.strip
  end

  def test_renders_a_row_with_a_remove_button_for_each_attached_file
    @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")

    fragment = render_inline(Moduler::Form::AttachmentsComponent.new(form, :attachments))
    row = fragment.at_css("ul[data-attachments-target='list'] li[data-attachment-id='#{@email.attachments.first.id}']")

    assert_equal "terms.pdf", row.at_css("a")&.text&.strip
    assert_match %r{\A/rails/active_storage/blobs/}, row.at_css("a")["href"]
    assert_equal "Remove", row.at_css("button[data-action='attachments#remove']")&.text&.strip
  end

  def test_does_not_render_rows_without_attached_files
    fragment = render_inline(Moduler::Form::AttachmentsComponent.new(form, :attachments))

    assert_empty fragment.css("ul[data-attachments-target='list'] li")
  end

  def test_does_not_render_unsaved_files
    email = Moduler::Email.new
    email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")

    fragment = render_inline(Moduler::Form::AttachmentsComponent.new(form(email), :attachments))

    assert_empty fragment.css("ul[data-attachments-target='list'] li")
  end

  def test_sets_the_field_name_for_removed_files
    fragment = render_inline(Moduler::Form::AttachmentsComponent.new(form, :attachments))

    assert_equal "email[remove_attachment_ids][]", fragment.at_css("[data-controller='attachments']")["data-attachments-remove-field-name-value"]
  end

  def test_renders_label_and_description_when_given
    fragment = render_inline(Moduler::Form::AttachmentsComponent.new(form, :attachments, label: "Attachments", description: "Any files"))

    assert_equal "Attachments", fragment.css("p").first&.text&.strip
    assert_equal "Any files", fragment.css("p").last&.text&.strip
  end

  def test_renders_error_when_field_is_invalid
    @email.errors.add(:attachments, "are too large")

    fragment = render_inline(Moduler::Form::AttachmentsComponent.new(form, :attachments))

    assert_equal "are too large", fragment.at_css("div.text-red-500")&.text&.strip
  end

  private

  def form(object = @email)
    Moduler::FormBuilder.new(:email, object, vc_test_controller.view_context, {})
  end
end
