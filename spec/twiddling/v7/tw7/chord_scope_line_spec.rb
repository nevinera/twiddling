describe Twiddling::V7::Tw7::ChordScopeLine do
  subject(:line) { described_class.new(line_number: 4, line_text: "T4::") }

  it "exposes line_number and line_text" do
    expect(line.line_number).to eq(4)
    expect(line.line_text).to eq("T4::")
  end

  it "starts with an empty children array" do
    expect(line.children).to be_empty
  end

  describe "#buttons" do
    it "parses the header button combination into a bitmask" do
      expect(line.buttons).to eq(0x1000)
    end

    it "returns 0 for the mousemode scope" do
      mm = described_class.new(line_number: 1, line_text: "[MOUSEMODE]::")
      expect(mm.buttons).to eq(0)
    end

    it "includes line number in error messages" do
      bad = described_class.new(line_number: 6, line_text: "ZZZ::")
      expect { bad.buttons }.to raise_error(ArgumentError, /Line 6/)
    end
  end

  describe "#mousemode?" do
    it "returns false for button scopes" do
      expect(line.mousemode?).to be false
    end

    it "returns true for the [MOUSEMODE] scope" do
      mm = described_class.new(line_number: 1, line_text: "[MOUSEMODE]::")
      expect(mm.mousemode?).to be true
    end
  end
end
