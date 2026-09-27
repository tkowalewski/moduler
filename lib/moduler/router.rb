module Moduler
  class Router
    def initialize(path, routes)
      @path = path
      @routes = routes
    end

    attr_reader :path, :routes
  end
end
