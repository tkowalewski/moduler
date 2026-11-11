module Moduler
  class FormBuilder < ActionView::Helpers::FormBuilder
    def error(field, options = {})
      return unless error?(field)

      @template.content_tag :div, **options do
        error_attributes(field).flat_map { |attribute| @object.errors[attribute] }.first
      end
    end

    def full_error(field, options = {})
      return unless error?(field)

      @template.content_tag :div, **options do
        error_attributes(field).flat_map { |attribute| @object.errors.full_messages_for(attribute) }.first
      end
    end

    def error?(field)
      @object.present? && error_attributes(field).any? { |attribute| @object.errors[attribute].try(:any?) }
    end

    private

    # The field itself and, for a foreign key field (e.g. moduler_user_id), the
    # belongs_to association it belongs to (e.g. user), which Rails validates.
    def error_attributes(field)
      [ field, belongs_to_association(field) ].compact
    end

    def belongs_to_association(field)
      return unless @object.class.respond_to?(:reflect_on_all_associations)

      @object.class.reflect_on_all_associations(:belongs_to).find { |association| association.foreign_key.to_s == field.to_s }&.name
    end
  end
end
