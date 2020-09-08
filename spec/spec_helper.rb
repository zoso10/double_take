# frozen_string_literal: true

require "bundler/setup"
require "double_take"
require "bundler"

require "pry-byebug"
require "climate_control"

require_relative "./support/gemfile_helper"

def resolve_bundler_version
  if !ENV["TEST_BUNDLER_VERSION"]
    Bundler::VERSION
  elsif ENV["TEST_BUNDLER_VERSION"] =~ /^\d+\.\d+$/
    short_version = ENV["TEST_BUNDLER_VERSION"]
    Gem::Specification
      .all_names
      .select { |n| n.start_with?("bundler") && n.include?(short_version) }
      .map { |n| Gem::Version.new(n.split("-").last) }
      .max
      .to_s
  else
    ENV["TEST_BUNDLER_VERSION"]
  end
end

ENV["TEST_BUNDLER_VERSION"] = resolve_bundler_version

puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts "Using Bundler version #{ENV['TEST_BUNDLER_VERSION']}"
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include GemfileHelper
end
