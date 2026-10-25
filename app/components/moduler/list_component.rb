# frozen_string_literal: true

module Moduler
  class ListComponent < ViewComponent::Base
    def initialize(collection, options = {})
      @collection = collection
      @options = options
    end

    def empty_message
      @options.fetch(:empty) { t("moduler.components.list.empty") }
    end

    def paginated?
      @collection.respond_to?(:total_pages)
    end
  end
end
