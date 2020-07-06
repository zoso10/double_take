# frozen_string_literal: true

require "bundler"
require "pathname"

require "double_take/clean"
require "double_take/hook"
require "double_take/version"

module DoubleTake
  GEMFILE = Bundler.default_gemfile
  GEMFILE_NEXT_LOCK = Pathname("#{GEMFILE}_next.lock")

  def with_dependency_next_override
    ENV["DEPENDENCY_NEXT_OVERRIDE"] = "1"

    yield
  ensure
    ENV.delete("DEPENDENCY_NEXT_OVERRIDE")
  end
end

DoubleTake::Clean.new.register_command
DoubleTake::Hook.new.register
