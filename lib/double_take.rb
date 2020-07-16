# frozen_string_literal: true

require "bundler"
require "pathname"

require "double_take/clean"
require "double_take/hook"
require "double_take/version"

module DoubleTake
  GEMFILE = Bundler.default_gemfile
  GEMFILE_NEXT_LOCK = Pathname("#{GEMFILE}_next.lock")

  def self.with_dependency_next
    ENV["DEPENDENCIES_NEXT"] = "1"

    yield
  ensure
    ENV.delete("DEPENDENCIES_NEXT")
  end

  def self.load
    DoubleTake::Clean.new.register_command
    hook = DoubleTake::Hook.new
    hook.bundle_next unless Bundler::Plugin.installed?("double_take")
    hook.register
  end
end
