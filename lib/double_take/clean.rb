# frozen_string_literal: true

module DoubleTake
  class Clean < Bundler::Plugin::API
    module Patch
      def next_specs
        ENV["DEPENDENCIES_NEXT"] = "1"
        deps = if Bundler.settings[:cache_all_platforms]
                 dependencies
               else
                 requested_dependencies
               end
        Bundler::Definition
          .build(GEMFILE, GEMFILE_NEXT_LOCK, nil)
          .resolve
          .materialize(deps)
      ensure
        ENV.delete("DEPENDENCIES_NEXT")
      end

      def specs
        super.merge(next_specs)
      end
    end

    def register_command
      self.class.command("double_take")
    end

    def exec(_command, args)
      return if !GEMFILE_NEXT_LOCK.file?

      if args.first != "clean"
        Bundler.ui.error("Unknown subcommand: '#{args.first}'")
        return
      end

      require "bundler/cli"
      require "bundler/cli/clean"

      Bundler::Definition.prepend(DoubleTake::Clean::Patch)

      options = {
        "dry-run": args.include?("--dry-run"),
        "force": args.include?("--force"),
      }
      Bundler::CLI::Clean.new(options).run
    end
  end
end
