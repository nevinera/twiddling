describe Twiddling::V7::Chord do
  subject(:chord) do
    described_class.new(bitmask: 0x00000002, modifier_type: 0x0002, keycode: 0x0006)
  end

  it "exposes attributes" do
    expect(chord.bitmask).to eq(0x00000002)
    expect(chord.modifier_type).to eq(0x0002)
    expect(chord.keycode).to eq(0x0006)
    expect(chord.string_keys).to be_nil
  end

  describe "#type_name" do
    it "returns :keyboard for type 0x02" do
      expect(chord.type_name).to eq(:keyboard)
    end

    it "returns :device for type 0x01" do
      chord = described_class.new(bitmask: 0, modifier_type: 0x0601, keycode: 0)
      expect(chord.type_name).to eq(:device)
    end

    it "returns :multichar for type 0x07" do
      chord = described_class.new(bitmask: 0, modifier_type: 0x0007, keycode: 0)
      expect(chord.type_name).to eq(:multichar)
    end
  end

  describe "#key_name" do
    it "looks up HID keycode" do
      expect(chord.key_name).to eq("c")
    end
  end

  describe "#modifier_names" do
    it "returns empty for no modifiers" do
      expect(chord.modifier_names).to be_empty
    end

    it "decodes shift" do
      chord = described_class.new(bitmask: 0, modifier_type: 0x2002, keycode: 0x1f)
      expect(chord.modifier_names).to eq(["Shift"])
    end

    it "decodes ctrl" do
      chord = described_class.new(bitmask: 0, modifier_type: 0x0102, keycode: 0x06)
      expect(chord.modifier_names).to eq(["Ctrl"])
    end
  end

  describe "#device_function" do
    it "returns the function for device chords" do
      chord = described_class.new(bitmask: 0, modifier_type: 0x0601, keycode: 0)
      expect(chord.device_function).to eq(:speed_cycle)
    end

    it "returns nil for non-device chords" do
      expect(chord.device_function).to be_nil
    end
  end

  describe "#mouse_mode?" do
    it "returns false without the flag" do
      expect(chord.mouse_mode?).to be false
    end

    it "returns true with the flag" do
      chord = described_class.new(bitmask: 0x00080002, modifier_type: 0x0201, keycode: 0)
      expect(chord.mouse_mode?).to be true
    end
  end

  describe "#==" do
    it "considers equal chords equal" do
      other = described_class.new(bitmask: 0x00000002, modifier_type: 0x0002, keycode: 0x0006)
      expect(chord).to eq(other)
    end

    it "considers different chords unequal" do
      other = described_class.new(bitmask: 0x00000002, modifier_type: 0x0002, keycode: 0x0007)
      expect(chord).not_to eq(other)
    end
  end
end
