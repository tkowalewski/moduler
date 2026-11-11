# frozen_string_literal: true

module Moduler
  class Form::SelectComponent < ViewComponent::Base
    def initialize(form, name, choices, options = {})
      @form = form
      @name = name
      @choices = choices
      @options = options
    end

    # Data attributes of the select, e.g. for Stimulus targets and actions.
    def data
      @options.fetch(:data, {})
    end
  end
end
