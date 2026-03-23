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

  describe "#set" do
    let(:config) { described_class.from_file(fixture_path("v7", "empty.cfg")) }

    it "returns a new Config with the attribute changed" do
      result = config.set(idle_time: 480)
      expect(result.idle_time).to eq(480)
      expect(result).not_to equal(config)
    end

    it "does not modify the original" do
      config.set(idle_time: 480)
      expect(config.idle_time).to eq(600)
    end

    it "preserves other attributes" do
      result = config.set(idle_time: 480)
      expect(result.key_repeat).to eq(config.key_repeat)
      expect(result.flags_1).to eq(config.flags_1)
      expect(result.chord_count).to eq(config.chord_count)
    end

    it "can set multiple attributes" do
      result = config.set(idle_time: 480, key_repeat: 50)
      expect(result.idle_time).to eq(480)
      expect(result.key_repeat).to eq(50)
    end

    it "can set flags" do
      result = config.set(flags_1: config.flags_1 & ~0x01)
      expect(result.flags_1 & 0x01).to eq(0)
    end

    it "produces a valid round-trippable binary" do
      result = config.set(idle_time: 480)
      roundtripped = described_class.from_binary(result.to_binary)
      expect(roundtripped.idle_time).to eq(480)
    end
  end

  describe "#with_settings" do
    let(:config) { described_class.from_file(fixture_path("v7", "empty.cfg")) }

    it "returns a new Config with replaced settings" do
      new_settings = Twiddling::V7::Settings.new(
        thumb_modifiers: [4, 0, 2, 0],
        dedicated_buttons: [0, 0, 0, 0],
        reserved: "\x00" * 12
      )
      result = config.with_settings(new_settings)
      expect(result.thumb_modifiers).to eq([4, 0, 2, 0])
      expect(result.dedicated_buttons).to eq([0, 0, 0, 0])
    end

    it "does not modify the original" do
      new_settings = Twiddling::V7::Settings.new(
        thumb_modifiers: [4, 0, 2, 0],
        dedicated_buttons: [0, 0, 0, 0],
        reserved: "\x00" * 12
      )
      config.with_settings(new_settings)
      expect(config.thumb_modifiers).to eq([0, 3, 1, 2])
    end
  end

  describe "#add_chord" do
    let(:config) { described_class.from_file(fixture_path("v7", "empty.cfg")) }
    let(:chord) { Twiddling::V7::Chord.new(bitmask: 0x00000004, modifier_type: 0x0002, keycode: 0x0007) }

    it "returns a new Config" do
      result = config.add_chord(chord)
      expect(result).to be_a(described_class)
      expect(result).not_to equal(config)
    end

    it "includes the new chord" do
      result = config.add_chord(chord)
      expect(result.chord_count).to eq(9)
      added = result.chords.find { |c| c.keycode == 0x0007 }
      expect(added).not_to be_nil
    end

    it "keeps chords sorted by bitmask" do
      result = config.add_chord(chord)
      bitmasks = result.chords.map(&:bitmask)
      expect(bitmasks).to eq(bitmasks.sort)
    end

    it "recomputes the index table" do
      result = config.add_chord(chord)
      expect(result.index_table).not_to eq(config.index_table)
    end

    it "does not modify the original" do
      config.add_chord(chord)
      expect(config.chord_count).to eq(8)
    end

    it "produces a valid round-trippable binary" do
      result = config.add_chord(chord)
      roundtripped = described_class.from_binary(result.to_binary)
      expect(roundtripped.chord_count).to eq(9)
    end
  end

  describe "#remove_chord" do
    let(:config) { described_class.from_file(fixture_path("v7", "single-unmodified-key.cfg")) }

    it "returns a new Config" do
      result = config.remove_chord(0x00000002)
      expect(result).to be_a(described_class)
      expect(result).not_to equal(config)
    end

    it "removes chords matching the bitmask low 16 bits" do
      result = config.remove_chord(0x00000002)
      matching = result.chords.select { |c| (c.bitmask & 0xFFFF) == 0x0002 }
      expect(matching).to be_empty
    end

    it "recomputes the index table" do
      result = config.remove_chord(0x00000002)
      expect(result.index_table).not_to eq(config.index_table)
    end

    it "does not modify the original" do
      original_count = config.chord_count
      config.remove_chord(0x00000002)
      expect(config.chord_count).to eq(original_count)
    end

    it "produces a valid round-trippable binary" do
      result = config.remove_chord(0x00000002)
      roundtripped = described_class.from_binary(result.to_binary)
      expect(roundtripped.chord_count).to eq(result.chord_count)
    end
  end
end
