# frozen_string_literal: true

module Moduler
  class ListItemComponent < ViewComponent::Base
    renders_many :badges, Moduler::BadgeComponent
    renders_one :meta
    renders_many :actions

    def initialize(title, options = {})
      @title = title
      @options = options
    end
  end
end
