# frozen_string_literal: true

require "bundler/setup"
require "double_take"
require "bundler"

require "pry-byebug"
require "climate_control"

require_relative "./support/gemfile_helper"

ENV["TEST_BUNDLER_VERSION"] ||= Bundler::VERSION

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include GemfileHelper
end
