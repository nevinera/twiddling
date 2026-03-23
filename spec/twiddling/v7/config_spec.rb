describe Twiddling::V7::Config do
  describe ".from_file" do
    subject(:config) { described_class.from_file(fixture_path("v7", "empty.cfg")) }

    it "delegates to Reader::Config" do
      expect(config).to be_a(described_class)
      expect(config.chord_count).to eq(8)
    end
  end

  describe ".from_binary" do
    it "delegates to Reader::Config" do
      data = File.binread(fixture_path("v7", "empty.cfg"))
      config = described_class.from_binary(data)
      expect(config).to be_a(described_class)
    end
  end

  describe "#to_binary" do
    it "delegates to Writer::Config" do
      data = File.binread(fixture_path("v7", "empty.cfg"))
      config = described_class.from_binary(data)
      expect(config.to_binary).to eq(data)
    end
  end

  describe "#chord_count" do
    it "returns the number of chords" do
      config = described_class.from_file(fixture_path("v7", "empty.cfg"))
      expect(config.chord_count).to eq(8)
    end
  end
end
