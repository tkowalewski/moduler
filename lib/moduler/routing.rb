module Moduler
  mattr_accessor :router

  module Routing
    def moduler(path, &block)
      Moduler.router = Router.new(path, block)

      mount Moduler::Engine => "/", as: :moduler
    end
  end
end
