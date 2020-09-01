# frozen_string_literal: true

require "bundler"
require "climate_control"

RSpec.describe DoubleTake::Hook do
  describe "#bundle_next" do
    let(:definition) { instance_double(Bundler::Definition) }
    let(:installer) { instance_double(Bundler::Installer) }

    before do
      allow(installer).to receive(:run)
      allow(Bundler::Installer).to receive(:new).and_return(installer)
      allow(Bundler::Definition).to receive(:build).and_return(definition)
      allow(Bundler.ui).to receive(:confirm)
    end

    it "no-ops if DEPENDENCIES_NEXT env var is set" do
      ClimateControl.modify DEPENDENCIES_NEXT: "1" do
        with_next_lockfile do |file|
          described_class.new.bundle_next(nil, file)

          expect(installer).not_to have_received(:run)
        end
      end
    end

    it "no-ops if Gemfile next lockfile does not exist" do
      ClimateControl.modify DEPENDENCIES_NEXT: nil do
        described_class.new.bundle_next

        expect(installer).not_to have_received(:run)
      end
    end

    it "installs the bundle for the Next lockfile" do
      with_next_lockfile do |file|
        unlock = {}

        described_class.new.bundle_next(unlock, file)

        expect(Bundler::Definition).to have_received(:build).with(
          DoubleTake::GEMFILE,
          file,
          unlock
        )
        expect(Bundler::Installer).to have_received(:new).with(
          Bundler.root,
          definition
        )
        expect(installer).to have_received(:run).with({})
      end
    end

    it "prints a message when installing bundle for the Next lockfile" do
      with_next_lockfile do |file|
        described_class.new.bundle_next(nil, file)

        expect(Bundler.ui).to have_received(:confirm).with(
          "Installing bundle for NEXT"
        )
      end
    end
  end
end
