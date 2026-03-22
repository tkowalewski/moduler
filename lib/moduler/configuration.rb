module Moduler
  class Configuration
    extend Forwardable

    def_delegator :@configuration, :[]
    def_delegator :@configuration, :dig

    def initialize
      @configuration = Rails.application.config_for(:moduler)
    end
  end
end
