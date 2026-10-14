# frozen_string_literal: true

module Moduler
  class Form::BaseErrorComponent < ViewComponent::Base
    def initialize(form)
      @form = form
    end
  end
end
