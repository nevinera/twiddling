describe Twiddling::V7::Writer::Settings do
  describe "#to_binary" do
    it "serializes settings to 32 bytes" do
      settings = Twiddling::V7::Settings.new(
        thumb_modifiers: [0, 3, 1, 2],
        dedicated_buttons: [0x0a, 0x0b, 0x09, 0x09],
        reserved: "\x00" * 12
      )
      binary = described_class.new(settings).to_binary
      expect(binary.length).to eq(32)
    end

    it "round-trips through Reader::Settings" do
      data = [0, 3, 1, 2].pack("V4") + [0x0a, 0x0b, 0x09, 0x09].pack("C4") + ("\x00" * 12)
      settings = Twiddling::V7::Reader::Settings.new(data).parse
      expect(described_class.new(settings).to_binary).to eq(data)
    end
  end
end
