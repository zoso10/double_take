# frozen_string_literal: true

require "fileutils"
require "open3"
require "tempfile"

module GemfileHelper
  def bundle_clean(gemfile_path, flag: "--dry-run")
    run_bundle("double_take clean", gemfile_path, flag: flag)
  end

  def bundle_install(gemfile_path, env: {})
    run_bundle("install", gemfile_path, env: env)
  end

  def plugin
    branch = %x(git rev-parse --abbrev-ref HEAD).strip

    "plugin 'double_take', git: '#{Bundler.root}', branch: '#{branch}'"
  end

  def with_gemfile(content: nil)
    dir = Dir.mktmpdir
    file = Tempfile.new("Gemfile", dir).tap do |f|
      f.write(content || <<~GEMFILE)
        source "https://rubygems.org"

        #{plugin}

        gem "rake"
      GEMFILE
      f.rewind
    end

    yield file
  ensure
    FileUtils.remove_dir(dir, true)
  end

  def with_next_lockfile
    dir = Dir.mktmpdir
    file = Tempfile.new("Gemfile_next.lock", dir).tap do |f|
      f.write("")
      f.rewind
    end
    yield Pathname(file)
  ensure
    FileUtils.remove_dir(dir, true)
  end

  private

  def run_bundle(command, gemfile_path, env: {}, flag: nil)
    output = nil
    bundler_version = Gem::Version.new(ENV.fetch("TEST_BUNDLER_VERSION"))
    command_execution = lambda do
      output, status = Open3.capture2e(
        { "BUNDLE_GEMFILE" => gemfile_path }.merge(env),
        "bundle _#{bundler_version}_ #{command} #{flag}"
      )

      raise "bundle #{command} failed: #{output}" unless status.success?
    end
    if bundler_version >= Gem::Version.new("2.1")
      Bundler.with_unbundled_env(&command_execution)
    else
      Bundler.with_clean_env(&command_execution)
    end
    output
  end
end
