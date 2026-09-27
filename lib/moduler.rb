require "moduler/version"
require "moduler/engine"
require "moduler/configuration"
require "moduler/router"
require "moduler/routing"

module Moduler
  def self.configuration
    @configuration ||= Configuration.new
  end
end

ActionDispatch::Routing::Mapper.include Moduler::Routing
