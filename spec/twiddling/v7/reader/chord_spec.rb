describe Twiddling::V7::Reader::Chord do
  describe "#parse" do
    context "keyboard chord (c, no modifier)" do
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x02, 0x00, 0x06, 0x00].pack("C*") }

      subject(:chord) { described_class.new(data).parse }

      it "returns a Chord" do
        expect(chord).to be_a(Twiddling::V7::Chord)
      end

      it "parses the bitmask" do
        expect(chord.bitmask).to eq(0x00000002)
      end

      it "parses modifier_type and keycode" do
        expect(chord.modifier_type).to eq(0x0002)
        expect(chord.keycode).to eq(0x0006)
      end

      it "has no string keys" do
        expect(chord.string_keys).to be_nil
      end
    end

    context "multi-char chord with string table" do
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00].pack("C*") }
      let(:table_data) { [0x0002, 0x0017, 0x0002, 0x0008, 0x0000, 0x0000].pack("v*") }
      let(:string_table) { Twiddling::V7::Reader::StringTable.new(table_data).parse }

      subject(:chord) { described_class.new(data, string_table: string_table).parse }

      it "resolves string keys from the table" do
        expect(chord.string_keys.length).to eq(2)
        expect(chord.string_keys.map { |k| k[:hid_code] }).to eq([0x17, 0x08])
      end
    end

    context "multi-char chord without string table" do
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00].pack("C*") }

      subject(:chord) { described_class.new(data).parse }

      it "has no string keys" do
        expect(chord.string_keys).to be_nil
      end
    end
  end

  describe "from fixtures" do
    it "parses a keyboard chord from single-unmodified-key.cfg" do
      data = File.binread(fixture_path("v7", "single-unmodified-key.cfg"))
      chord = described_class.new(data[0x80, 8]).parse
      expect(chord.key_name).to eq("c")
      expect(chord.modifier_names).to be_empty
    end

    it "parses a shifted chord from shifted-key.cfg" do
      data = File.binread(fixture_path("v7", "shifted-key.cfg"))
      chord = described_class.new(data[0x80, 8]).parse
      expect(chord.modifier_names).to eq(["Shift"])
    end

    it "parses a device function from empty.cfg" do
      data = File.binread(fixture_path("v7", "empty.cfg"))
      chord = described_class.new(data[0x80, 8]).parse
      expect(chord.device_function).to eq(:speed_cycle)
    end
  end
end
