# frozen_string_literal: true

module Moduler
  class BadgeComponent < ViewComponent::Base
    def initialize(text, options = {})
      @text = text
      @variant = options.fetch(:variant, :neutral)
    end
  end
end
