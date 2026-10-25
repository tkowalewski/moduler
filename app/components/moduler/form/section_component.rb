# frozen_string_literal: true

module Moduler
  class Form::SectionComponent < ViewComponent::Base
    def initialize(title, options = {})
      @title = title
      @options = options
    end

    def divider?
      @options[:divider]
    end
  end
end
