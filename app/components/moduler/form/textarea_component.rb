# frozen_string_literal: true

module Moduler
  class Form::TextareaComponent < ViewComponent::Base
    def initialize(form, name, options = {})
      @form = form
      @name = name
      @options = options
    end
  end
end
