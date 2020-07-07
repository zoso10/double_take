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
end
