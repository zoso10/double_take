# frozen_string_literal: true

module DoubleTake
  class Hook < Bundler::Plugin::API
    def register
      self.class.hook("before-install-all") do
        @previous_lockfile = Bundler.default_lockfile.read
      end

      self.class.hook("after-install-all") do
        next if ENV["DEPENDENCY_NEXT_OVERRIDE"]

        current_definition = Bundler.definition
        unlock = current_definition.instance_variable_get(:@unlock)

        with_dependency_next_override do
          next_definition = Bundler::Definition
            .build(GEMFILE, GEMFILE_NEXT_LOCK, unlock)

          if current_definition.to_lock == @previous_lockfile
            Bundler.ui.confirm("Installing bundle for NEXT")

            # TODO: pass options parameter to installer
            Bundler::Installer.new(Bundler.root, next_definition).run({})
          end
        end
      end
    end
  end
end
