# frozen_string_literal: true

module Moduler
  class FilterComponent < ViewComponent::Base
    def initialize(filter, url, options = {})
      @filter = filter
      @url = url
      @options = options
    end

    def placeholder
      @options.fetch(:placeholder) { t("moduler.components.filter.placeholder.query") }
    end
  end
end
