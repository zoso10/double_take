# frozen_string_literal: true

RSpec.describe DoubleTake do
  include described_class

  describe "#with_dependency_next_override" do
    it "yields to the block" do
      expect do |block|
        with_dependency_next_override(&block)
      end.to yield_control
    end

    it "sets an env var" do
      expect(ENV["DEPENDENCY_NEXT_OVERRIDE"]).not_to eq("1")
      with_dependency_next_override do
        expect(ENV["DEPENDENCY_NEXT_OVERRIDE"]).to eq("1")
      end
    end

    it "ensures the environment variable is unset" do
      expect do
        with_dependency_next_override do
          raise
        end
      end.to raise_error(RuntimeError)
      expect(ENV["DEPENDENCY_NEXT_OVERRIDE"]).not_to eq("1")
    end
  end
end
