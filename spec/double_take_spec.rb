# frozen_string_literal: true

RSpec.describe DoubleTake do
  describe ".with_dependency_next" do
    it "yields to the block" do
      expect do |block|
        described_class.with_dependency_next(&block)
      end.to yield_control
    end

    it "sets an env var" do
      expect(ENV["DEPENDENCIES_NEXT"]).not_to eq("1")
      described_class.with_dependency_next do
        expect(ENV["DEPENDENCIES_NEXT"]).to eq("1")
      end
    end

    it "ensures the environment variable is unset" do
      expect do
        described_class.with_dependency_next do
          raise
        end
      end.to raise_error(RuntimeError)
      expect(ENV["DEPENDENCIES_NEXT"]).not_to eq("1")
    end
  end

  describe "`bundle install` behaviour" do
    it "does not bundle for Next when Next lockfile does not exist" do
      with_gemfile do |file|
        output = bundle_install(file.path)

        expect(output).not_to include("Installing bundle for NEXT")
      end
    end

    it "bundles for Next when Next lockfile is present" do
      with_gemfile do |file|
        bundle_install(file.path)
        FileUtils.cp("#{file.path}.lock", "#{file.path}_next.lock")

        output = bundle_install(file.path)

        expect(output).to include("Installing bundle for NEXT")
      end
    end

    it "bundles for Next on inital bundle install after plugin is added" do
      without_plugin = <<~GEMFILE
        source "https://rubygems.org"

        gem "rake"
      GEMFILE

      with_gemfile(content: without_plugin) do |file|
        bundle_install(file.path)
        FileUtils.cp("#{file.path}.lock", "#{file.path}_next.lock")
        output = bundle_install(file.path)

        expect(output).not_to include("Installing bundle for NEXT")

        File.write(file, plugin, mode: "a")

        output = bundle_install(file.path)

        expect(output).to include("Installing bundle for NEXT")
      end
    end

    it "doesn't bundle Next when DEPENDENCIES_NEXT env var is set" do
      with_gemfile do |file|
        bundle_install(file.path)
        FileUtils.cp("#{file.path}.lock", "#{file.path}_next.lock")

        output = bundle_install(file.path, env: { "DEPENDENCIES_NEXT" => "1" })

        expect(output).not_to include("Installing bundle for NEXT")
      end
    end
  end

  describe "`bundle clean` behaviour" do
    it "keeps gems in both lockfiles" do
      multiple_versions = <<~GEMFILE
        source "https://rubygems.org"
        #{plugin}

        if ENV["DEPENDENCIES_NEXT"]
          gem "rake", "13.0.1"
        else
          gem "rake", "12.3.3"
        end
      GEMFILE

      with_gemfile(content: multiple_versions) do |file|
        bundle_install(file.path)
        FileUtils.cp("#{file.path}.lock", "#{file.path}_next.lock")
        bundle_install(file.path, env: { "DEPENDENCIES_NEXT" => "1" })

        # The versions are backwards with what you'd expect for "Next",
        # but that's not what we're testing here so it's fine
        version = Bundler::Definition
          .build(file.path, "#{file.path}.lock", DoubleTake::Hook::EMPTY_UNLOCK)
          .locked_deps["rake"]
          .requirement
          .to_s
        expect(version).to eq("= 13.0.1")
        next_version = Bundler::Definition
          .build(file.path, "#{file.path}_next.lock", DoubleTake::Hook::EMPTY_UNLOCK)
          .locked_deps["rake"]
          .requirement
          .to_s
        expect(next_version).to eq("= 12.3.3")

        output = bundle_clean(file.path)

        expect(output).not_to include("rake (13.0.1)")
        expect(output).not_to include("rake (12.3.3)")
      end
    end

    it "supports `clean` subcommand flags" do
      with_gemfile do |file|
        bundle_install(file.path)

        output = bundle_clean(file.path, flag: "--help")

        expect(output).to include("Cleans up unused gems in your bundler directory")
      end
    end
  end
end
