require "moduler/version"
require "moduler/engine"
require "moduler/configuration"

module Moduler
  def self.configuration
    @configuration ||= Configuration.new
  end
end
