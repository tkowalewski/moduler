# frozen_string_literal: true

module Moduler
  # Files of a has_many_attached association, one row per file. Rows of new
  # files are added with a button, and each row (new or attached) can be
  # removed. Attached files marked for removal are submitted as
  # remove_<name singular>_ids[] (e.g. remove_attachment_ids[]) and removed
  # by the controller when the form is saved.
  class Form::AttachmentsComponent < ViewComponent::Base
    def initialize(form, name, options = {})
      @form = form
      @name = name
      @options = options
    end

    def attached
      @form.object.public_send(@name).select(&:persisted?)
    end

    def field_name
      "#{@form.object_name}[#{@name}][]"
    end

    def remove_field_name
      "#{@form.object_name}[remove_#{@name.to_s.singularize}_ids][]"
    end
  end
end
