require "view_component"
require "pg_search"
require "pundit"
require "active_storage/engine"

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
