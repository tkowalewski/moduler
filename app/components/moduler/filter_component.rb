# frozen_string_literal: true

module Moduler
  class FilterComponent < ViewComponent::Base
    # options:
    #   placeholder: placeholder of the query field
    #   selects: additional select fields, each a hash with
    #     name (filter attribute), choices ([label, value] pairs) and prompt (label of the empty choice)
    def initialize(filter, url, options = {})
      @filter = filter
      @url = url
      @options = options
    end

    def placeholder
      @options.fetch(:placeholder) { t("moduler.components.filter.placeholder.query") }
    end

    def selects
      @options.fetch(:selects, [])
    end

    def filtered?
      @filter.query.present? || selects.any? { |select| @filter.public_send(select[:name]).present? }
    end
  end
end
