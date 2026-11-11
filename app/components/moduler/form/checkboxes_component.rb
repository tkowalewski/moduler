# frozen_string_literal: true

module Moduler
  class Form::CheckboxesComponent < ViewComponent::Base
    # choices: array of [label, value] pairs
    def initialize(form, name, choices, options = {})
      @form = form
      @name = name
      @choices = choices
      @options = options
    end
  end
end
