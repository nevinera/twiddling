describe Twiddling::V7::Tw7::ChordLine do
  subject(:line) { described_class.new(line_number: 5, line_text: "1R: c") }

  it "exposes line_number and line_text" do
    expect(line.line_number).to eq(5)
    expect(line.line_text).to eq("1R: c")
  end

  describe "#buttons" do
    it "parses the button combination into a bitmask" do
      expect(line.buttons).to eq(0x0002)
    end

    it "includes line number in error messages" do
      bad = described_class.new(line_number: 7, line_text: "ZZZ: c")
      expect { bad.buttons }.to raise_error(ArgumentError, /Line 7/)
    end
  end

  describe "#value" do
    it "returns a parsed effect hash" do
      expect(line.value).to include(keycode: 0x06)
    end

    it "parses modified keys" do
      line = described_class.new(line_number: 1, line_text: "1R: ctrl+c")
      expect(line.value[:modifier_type]).to be > 0
    end

    it "includes line number in error messages" do
      bad = described_class.new(line_number: 9, line_text: "1R: zzz")
      expect { bad.value }.to raise_error(ArgumentError, /Line 9/)
    end
  end
end
