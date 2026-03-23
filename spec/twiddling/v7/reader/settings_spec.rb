describe Twiddling::V7::Reader::Settings do
  describe "#parse" do
    # Default settings from empty.cfg at offset 0x40
    let(:data) do
      # thumb_modifiers: [0, 3, 1, 2], dedicated: [0x0a, 0x0b, 0x09, 0x09], reserved: 12 zeros
      [0, 3, 1, 2].pack("V4") + [0x0a, 0x0b, 0x09, 0x09].pack("C4") + ("\x00" * 12)
    end

    subject(:settings) { described_class.new(data).parse }

    it "returns a Settings" do
      expect(settings).to be_a(Twiddling::V7::Settings)
    end

    it "parses thumb modifiers" do
      expect(settings.thumb_modifiers).to eq([0, 3, 1, 2])
    end

    it "parses dedicated buttons" do
      expect(settings.dedicated_buttons).to eq([0x0a, 0x0b, 0x09, 0x09])
    end

    it "parses reserved bytes" do
      expect(settings.reserved).to eq("\x00" * 12)
    end
  end

  describe "from fixtures" do
    it "parses no-right-mouse-button settings" do
      data = File.binread(fixture_path("v7", "no-right-mouse-button.cfg"))
      settings = described_class.new(data[0x40, 32]).parse
      expect(settings.dedicated_buttons[0]).to eq(0x00)
    end

    it "parses no-t0-dedicated settings" do
      data = File.binread(fixture_path("v7", "no-t0-dedicated.cfg"))
      settings = described_class.new(data[0x40, 32]).parse
      expect(settings.dedicated_buttons[3]).to eq(0x00)
    end

    it "parses ericspace thumb modifiers" do
      data = File.binread(fixture_path("v7", "large.cfg"))
      settings = described_class.new(data[0x40, 32]).parse
      expect(settings.thumb_modifiers).to eq([4, 0, 2, 0])
    end
  end
end
