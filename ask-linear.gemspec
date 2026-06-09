require_relative "lib/ask/linear/version"

Gem::Specification.new do |spec|
  spec.name = "ask-linear"
  spec.version = Ask::Linear::VERSION
  spec.authors = ["Kaka Ruto"]
  spec.email = ["kaka@myrrlabs.com"]

  spec.summary = "Linear service context for the ask-rb ecosystem"
  spec.description = "Provides authenticated client helper, context metadata, and error guide for AI agents."
  spec.homepage = "https://github.com/ask-rb/ask-linear"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ask-auth", "~> 0.1"

  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "mocha", "~> 3.1"
  spec.add_development_dependency "rake", "~> 13.0"
end
