# frozen_string_literal: true

module Moduler
  class Form::EmailComponent < ViewComponent::Base
    def initialize(form, name, options = {})
      @form = form
      @name = name
      @options = options
    end
  end
end
