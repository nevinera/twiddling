describe Twiddling::V7::Writer::Chord do
  describe "#to_binary" do
    it "serializes a keyboard chord" do
      chord = Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x2002, keycode: 0x1f)
      binary = described_class.new(chord).to_binary
      expect(binary).to eq([0x02, 0x00, 0x00, 0x00, 0x02, 0x20, 0x1f, 0x00].pack("C*"))
    end

    it "serializes a device chord" do
      chord = Twiddling::V7::Chord.new(bitmask: 0x3001, modifier_type: 0x0601, keycode: 0)
      binary = described_class.new(chord).to_binary
      expect(binary).to eq([0x01, 0x30, 0x00, 0x00, 0x01, 0x06, 0x00, 0x00].pack("C*"))
    end

    it "encodes string_table_offset into modifier_type for multichar" do
      chord = Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x0007, keycode: 0)
      binary = described_class.new(chord, string_table_offset: 0x14).to_binary
      _, mod_type, _ = binary.unpack("Vvv")
      expect(mod_type).to eq(0x1407)
    end

    it "preserves modifier_type when no offset given" do
      chord = Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x0002, keycode: 0x06)
      binary = described_class.new(chord).to_binary
      _, mod_type, _ = binary.unpack("Vvv")
      expect(mod_type).to eq(0x0002)
    end
  end

  describe "round-trip with Reader::Chord" do
    it "round-trips a keyboard chord" do
      data = [0x02, 0x00, 0x00, 0x00, 0x02, 0x20, 0x1f, 0x00].pack("C*")
      chord = Twiddling::V7::Reader::Chord.new(data).parse
      expect(described_class.new(chord).to_binary).to eq(data)
    end

    it "round-trips a device chord" do
      data = [0x01, 0x30, 0x00, 0x00, 0x01, 0x06, 0x00, 0x00].pack("C*")
      chord = Twiddling::V7::Reader::Chord.new(data).parse
      expect(described_class.new(chord).to_binary).to eq(data)
    end
  end
end
