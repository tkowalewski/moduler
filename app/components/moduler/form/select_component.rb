# frozen_string_literal: true

module Moduler
  class Form::SelectComponent < ViewComponent::Base
    def initialize(form, name, choices, options = {})
      @form = form
      @name = name
      @choices = choices
      @options = options
    end
  end
end
