# frozen_string_literal: true

module Moduler
  class ButtonLinkComponent < ViewComponent::Base
    def initialize(text, url, options = {})
      @text = text
      @url = url
      @options = options
    end

    def small?
      @options[:size] == :sm
    end
  end
end
