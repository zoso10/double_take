# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "double_take/version"

Gem::Specification.new do |spec|
  spec.name = "double_take"
  spec.version = DoubleTake::VERSION
  spec.authors = ["Tyler Ewing"]
  spec.email = ["tewing10@gmail.com"]

  spec.summary = "A bundler plugin to install multiple sets of dependencies."
  spec.homepage = "https://github.com/zoso10/double_take"
  spec.license = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "https://github.com/zoso10/double_take/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.17.0", "< 2.2"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.90"
end
