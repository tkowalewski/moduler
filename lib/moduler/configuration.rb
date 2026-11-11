module Moduler
  class Configuration
    extend Forwardable

    def_delegator :@configuration, :[]
    def_delegator :@configuration, :dig

    def initialize
      @configuration = Rails.application.config_for(:moduler)
    end

    # Permissions that can be granted to organization roles, defined under
    # `permissions` in config/moduler.yml.
    def permissions
      Array(dig(:permissions)).map(&:to_s)
    end
  end
end
