# frozen_string_literal: true

require "bundler/cli"
require "bundler/cli/clean"

RSpec.describe DoubleTake::Clean do
  describe "#exec" do
    let(:clean) { instance_double(Bundler::CLI::Clean) }

    before do
      allow(clean).to receive(:run)
      allow(Bundler::CLI::Clean).to receive(:new).and_return(clean)
      allow(Bundler.ui).to receive(:error)
    end

    it "no-ops if Next lockfile does not exist" do
      described_class.new.exec(nil, nil)

      expect(clean).not_to have_received(:run)
    end

    it "errors if not given the `clean` subcommand" do
      with_next_lockfile do |file|
        stub_const("DoubleTake::GEMFILE_NEXT_LOCK", file)

        described_class.new.exec(nil, ["soil"])

        expect(Bundler.ui).to have_received(:error).with(
          "Unknown subcommand: 'soil'"
        )
        expect(clean).not_to have_received(:run)
      end
    end

    it "prepends a bundler clean monkeypatch" do
      with_next_lockfile do |file|
        stub_const("DoubleTake::GEMFILE_NEXT_LOCK", file)
        allow(Bundler::Definition).to receive(:prepend)

        described_class.new.exec(nil, ["clean"])

        expect(Bundler::Definition).to have_received(:prepend).with(
          described_class::Patch
        )
      end
    end

    it "calls the `clean` subcommand with its options" do
      with_next_lockfile do |file|
        stub_const("DoubleTake::GEMFILE_NEXT_LOCK", file)

        described_class.new.exec(nil, ["clean", "--force", "--dry-run"])

        expect(Bundler::CLI::Clean).to have_received(:new).with(
          "dry-run": true,
          "force": true,
        )
        expect(clean).to have_received(:run)
      end
    end
  end
end
