describe Twiddling::V7::Chord do
  describe ".from_binary" do
    context "keyboard chord (F1R = c, no modifier)" do
      # bitmask 0x00000002, modifier_type 0x0002, keycode 0x0006
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x02, 0x00, 0x06, 0x00].pack("C*") }

      subject(:chord) { described_class.from_binary(data) }

      it "parses the bitmask" do
        expect(chord.bitmask).to eq(0x00000002)
      end

      it "identifies as keyboard" do
        expect(chord.type_name).to eq(:keyboard)
      end

      it "decodes the key" do
        expect(chord.key_name).to eq("c")
      end

      it "has no modifiers" do
        expect(chord.modifier_names).to be_empty
      end

      it "has no string keys" do
        expect(chord.string_keys).to be_nil
      end

      it "is not mouse mode" do
        expect(chord.mouse_mode?).to be false
      end
    end

    context "shifted keyboard chord (F1R = @)" do
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x02, 0x20, 0x1f, 0x00].pack("C*") }

      subject(:chord) { described_class.from_binary(data) }

      it "decodes shift modifier" do
        expect(chord.modifier_names).to eq(["Shift"])
      end

      it "decodes the base key" do
        expect(chord.key_name).to eq("2")
      end
    end

    context "modifier chord (F1R = ctrl+c)" do
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x02, 0x01, 0x06, 0x00].pack("C*") }

      subject(:chord) { described_class.from_binary(data) }

      it "decodes ctrl modifier" do
        expect(chord.modifier_names).to eq(["Ctrl"])
      end
    end

    context "device function chord (speed cycle)" do
      let(:data) { [0x01, 0x30, 0x00, 0x00, 0x01, 0x06, 0x00, 0x00].pack("C*") }

      subject(:chord) { described_class.from_binary(data) }

      it "identifies as device" do
        expect(chord.type_name).to eq(:device)
      end

      it "decodes the function" do
        expect(chord.device_function).to eq(:speed_cycle)
      end
    end

    context "mouse-mode chord" do
      let(:data) { [0x02, 0x00, 0x08, 0x00, 0x01, 0x02, 0x00, 0x00].pack("C*") }

      subject(:chord) { described_class.from_binary(data) }

      it "detects mouse mode flag" do
        expect(chord.mouse_mode?).to be true
      end
    end

    context "multi-char chord with string table" do
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00].pack("C*") }
      let(:table_data) { [0x0002, 0x0017, 0x0002, 0x0008, 0x0000, 0x0000].pack("v*") }
      let(:string_table) { Twiddling::V7::Reader::StringTable.new(table_data).parse }

      subject(:chord) { described_class.from_binary(data, string_table: string_table) }

      it "identifies as multichar" do
        expect(chord.type_name).to eq(:multichar)
      end

      it "decodes string keys" do
        expect(chord.string_keys.length).to eq(2)
        expect(chord.string_keys.map { |k| k[:hid_code] }).to eq([0x17, 0x08])
      end
    end

    context "multi-char chord without string table" do
      let(:data) { [0x02, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00].pack("C*") }

      subject(:chord) { described_class.from_binary(data) }

      it "has no string keys" do
        expect(chord.string_keys).to be_nil
      end
    end
  end

  describe "#to_binary" do
    it "round-trips a keyboard chord" do
      data = [0x02, 0x00, 0x00, 0x00, 0x02, 0x20, 0x1f, 0x00].pack("C*")
      chord = described_class.from_binary(data)
      expect(chord.to_binary).to eq(data)
    end

    it "round-trips a device chord" do
      data = [0x01, 0x30, 0x00, 0x00, 0x01, 0x06, 0x00, 0x00].pack("C*")
      chord = described_class.from_binary(data)
      expect(chord.to_binary).to eq(data)
    end

    it "accepts a string_table_offset override for multichar chords" do
      chord = described_class.new(bitmask: 0x02, modifier_type: 0x0007, keycode: 0)
      binary = chord.to_binary(string_table_offset: 0x14)
      _, mod_type, _ = binary.unpack("Vvv")
      expect(mod_type).to eq(0x1407)
    end
  end

  describe "from fixture data" do
    it "parses the first chord from single-unmodified-key.cfg" do
      data = File.binread(fixture_path("v7", "single-unmodified-key.cfg"))
      chord = described_class.from_binary(data[0x80, 8])
      expect(chord.type_name).to eq(:keyboard)
      expect(chord.key_name).to eq("c")
      expect(chord.modifier_names).to be_empty
    end

    it "parses the first chord from modifier-key.cfg" do
      data = File.binread(fixture_path("v7", "modifier-key.cfg"))
      chord = described_class.from_binary(data[0x80, 8])
      expect(chord.type_name).to eq(:keyboard)
      expect(chord.key_name).to eq("c")
      expect(chord.modifier_names).to eq(["Ctrl"])
    end

    it "parses the first chord from shifted-key.cfg" do
      data = File.binread(fixture_path("v7", "shifted-key.cfg"))
      chord = described_class.from_binary(data[0x80, 8])
      expect(chord.modifier_names).to eq(["Shift"])
      expect(chord.key_name).to eq("2")
    end

    it "parses the speed_cycle chord from empty.cfg" do
      data = File.binread(fixture_path("v7", "empty.cfg"))
      chord = described_class.from_binary(data[0x80, 8])
      expect(chord.type_name).to eq(:device)
      expect(chord.device_function).to eq(:speed_cycle)
    end

    it "parses the cycle_config chord" do
      data = File.binread(fixture_path("v7", "cycle-config-chord.cfg"))
      chord = described_class.from_binary(data[0x80, 8])
      expect(chord.device_function).to eq(:config_cycle)
    end
  end
end
