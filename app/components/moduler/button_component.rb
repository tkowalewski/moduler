# frozen_string_literal: true

module Moduler
  class ButtonComponent < ViewComponent::Base
    def initialize(text, url, options = {})
      @text = text
      @url = url
      @options = options
    end

    def small?
      @options[:size] == :sm
    end

    def form_options
      { class: "shrink-0", data: { turbo_confirm: @options[:confirm] }.compact }
    end
  end
end
