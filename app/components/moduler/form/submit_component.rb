# frozen_string_literal: true

module Moduler
  class Form::SubmitComponent < ViewComponent::Base
    def initialize(form, options = {})
      @form = form
      @options = options
    end
  end
end
