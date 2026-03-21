require_relative "lib/moduler/version"

Gem::Specification.new do |spec|
  spec.name        = "moduler"
  spec.version     = Moduler::VERSION
  spec.authors     = [ "Tomasz Kowalewski" ]
  spec.email       = [ "me@tkowalewski.pl" ]
  spec.homepage    = "https://github.com/tkowalewski/moduler"
  spec.summary     = "Moduler 🔥"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tkowalewski/moduler"
  spec.metadata["changelog_uri"] = "https://github.com/tkowalewski/moduler/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.2.0"
  spec.add_dependency "rails", "~> 8.1", ">= 8.1.2"
  spec.add_dependency "importmap-rails", "~> 2.2", ">= 2.2.3"
  spec.add_dependency "stimulus-rails", "~> 1.3", ">= 1.3.4"
  spec.add_dependency "tailwindcss-rails", "~> 4.4"
end
