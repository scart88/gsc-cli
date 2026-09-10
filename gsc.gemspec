# frozen_string_literal: true

require_relative "lib/gsc/version"

Gem::Specification.new do |spec|
  spec.name          = "gsc-cli"
  spec.version       = GSC::VERSION
  spec.authors       = ["ApollosWave LLC"]
  spec.email         = ["support@apolloswave.com"]

  spec.summary       = "Google Search Console, Google Indexing API, Keyword Intelligence & Real-Time Trends CLI"
  spec.description   = "A lightweight, zero-gem CLI tool and AI agent engine for Google Search Console, Google Indexing API, Google Analytics 4, Keywords Everywhere, and Google Trends."
  spec.homepage      = "https://github.com/ApollosWave/gsc-cli"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files         = Dir["lib/**/*", "bin/*", "dist/*", "README.md", "LICENSE"]
  spec.bindir        = "bin"
  spec.executables   = ["gsc"]
  spec.require_paths = ["lib"]

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/README.md"
end
