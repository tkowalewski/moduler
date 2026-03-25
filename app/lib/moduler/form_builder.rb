module Moduler
  class FormBuilder < ActionView::Helpers::FormBuilder
    def error(field, options = {})
      return unless error?(field)

      @template.content_tag :div, **options do
        @object.errors[field].first
      end.html_safe
    end

    def full_error(field, options = {})
      return unless error?(field)

      @template.content_tag :div, **options do
        @object.errors.full_messages_for(field).first
      end.html_safe
    end

    def error?(field)
      @object && @object.errors[field].try(:any?)
    end
  end
end
