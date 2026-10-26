# frozen_string_literal: true

module Moduler
  class Form::WysiwygComponent < ViewComponent::Base
    ACTIONS = {
      bold: "font-semibold",
      italic: "italic",
      h1: "font-semibold",
      h2: "font-semibold",
      h3: "font-semibold",
      quote: "",
      code: "font-mono",
      ul: "",
      ol: "",
      fencedCode: "font-mono",
      link: "",
      image: ""
    }.freeze

    def initialize(form, name, options = {})
      @form = form
      @name = name
      @options = options
    end

    def rows
      @options.fetch(:rows, 14)
    end

    # Name of the has_many_attached association that receives uploaded images,
    # `attachments: false` disables uploading.
    def attachments
      @options.fetch(:attachments, :images)
    end

    def upload?
      attachments.present? && @form.object.respond_to?(attachments)
    end

    def attachments_field_name
      "#{@form.object_name}[#{attachments}][]"
    end

    # Assigning has_many_attached replaces existing attachments, so already attached
    # blobs are submitted again together with the newly uploaded ones.
    def attached_signed_ids
      @form.object.public_send(attachments).map { |attachment| attachment.blob.signed_id }
    end

    def controller_data
      data = { controller: "wysiwyg" }
      return data unless upload?

      data.merge(
        wysiwyg_direct_upload_url_value: helpers.main_app.rails_direct_uploads_path,
        wysiwyg_blob_url_value: helpers.main_app.rails_service_blob_path(":signed_id", ":filename"),
        wysiwyg_attachments_field_name_value: attachments_field_name
      )
    end
  end
end
