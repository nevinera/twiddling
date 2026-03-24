describe Twiddling::V7::Tw7::SettingsLine do
  subject(:line) { described_class.new(line_number: 3, line_text: "idle_time: 480") }

  it "exposes line_number and line_text" do
    expect(line.line_number).to eq(3)
    expect(line.line_text).to eq("idle_time: 480")
  end

  describe "#key" do
    it "returns the setting name" do
      expect(line.key).to eq("idle_time")
    end
  end

  describe "#value" do
    it "returns the setting value as a string" do
      expect(line.value).to eq("480")
    end

    it "handles values containing colons" do
      line = described_class.new(line_number: 1, line_text: "some_key: a:b")
      expect(line.value).to eq("a:b")
    end
  end
end
