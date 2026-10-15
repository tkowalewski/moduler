# frozen_string_literal: true

module Moduler
  class SidebarActionComponent < ViewComponent::Base
    def initialize(action, route, expected_controller)
      @action = action
      @route = route
      @expected_controller = expected_controller
    end

    def active?
      controller_path.eql?(@expected_controller)
    end
  end
end
