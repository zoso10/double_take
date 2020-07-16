# frozen_string_literal: true

module DoubleTake
  class Hook < Bundler::Plugin::API
    EMPTY_ARRAY = [].freeze
    EMPTY_UNLOCK = { gems: EMPTY_ARRAY, sources: EMPTY_ARRAY, ruby: false }.freeze

    def register
      self.class.hook("before-install-all") do
        next if !GEMFILE_NEXT_LOCK.file?

        @previous_lockfile = Bundler.default_lockfile.read
      end

      self.class.hook("after-install-all") do
        next if ENV["DEPENDENCIES_NEXT"] || !GEMFILE_NEXT_LOCK.file?

        current_definition = Bundler.definition
        unlock = current_definition.instance_variable_get(:@unlock)

        if current_definition.to_lock == @previous_lockfile
          bundle_next(unlock)
        end
      end
    end

    def bundle_next(unlock = EMPTY_UNLOCK)
      return if ENV["DEPENDENCIES_NEXT"] || !GEMFILE_NEXT_LOCK.file?

      # this method memoizes an instance of the current definition
      # so we need to fill that cache for other bundler internals to use
      Bundler.definition

      DoubleTake.with_dependency_next do
        next_definition = Bundler::Definition
          .build(GEMFILE, GEMFILE_NEXT_LOCK, unlock)

        Bundler.ui.confirm("Installing bundle for NEXT")

        # TODO: pass options parameter to installer
        Bundler::Installer.new(Bundler.root, next_definition).run({})
      end
    end
  end
end
