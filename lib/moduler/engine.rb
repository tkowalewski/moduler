require "importmap-rails"
require "stimulus-rails"
require "tailwindcss-rails"

module Moduler
  class Engine < ::Rails::Engine
    isolate_namespace Moduler

    initializer "moduler.importmap", before: "importmap" do |app|
      app.config.importmap.paths += [ Engine.root.join("config/importmap.rb") ]
    end

    initializer "moduler.assets" do |app|
      app.config.assets.precompile += %w[moduler/manifest.js]
    end
  end
end
