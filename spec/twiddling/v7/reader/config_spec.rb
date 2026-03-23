describe Twiddling::V7::Reader::Config do
  subject(:config) { described_class.new(data).parse }

  let(:data) { File.binread(fixture_path("v7", fixture_name)) }

  describe "empty.cfg" do
    let(:fixture_name) { "empty.cfg" }

    it "returns a Config" do
      expect(config).to be_a(Twiddling::V7::Config)
    end

    it "parses header fields" do
      expect(config.version).to eq(0)
      expect(config.format_version).to eq(7)
      expect(config.idle_time).to eq(600)
      expect(config.key_repeat).to eq(100)
    end

    it "parses flags" do
      expect(config.flags_1).to eq(0x09)
      expect(config.flags_2).to eq(0x20)
      expect(config.flags_3).to eq(0x00)
    end

    it "parses thumb modifier assignments" do
      expect(config.thumb_modifiers).to eq([0, 3, 1, 2])
    end

    it "parses dedicated button functions" do
      expect(config.dedicated_buttons).to eq([0x0a, 0x0b, 0x09, 0x09])
    end

    it "parses the index table" do
      expect(config.index_table.length).to eq(32)
    end

    it "parses chords" do
      expect(config.chord_count).to eq(8)
      expect(config.chords.first).to be_a(Twiddling::V7::Chord)
    end
  end

  describe "settings fixtures" do
    it "parses idle_time from idle-time-8m.cfg" do
      config = described_class.new(File.binread(fixture_path("v7", "idle-time-8m.cfg"))).parse
      expect(config.idle_time).to eq(480)
    end

    it "parses key_repeat from key-repeat-1020.cfg" do
      config = described_class.new(File.binread(fixture_path("v7", "key-repeat-1020.cfg"))).parse
      expect(config.key_repeat).to eq(102)
    end

    it "parses key-repeat-disabled flags" do
      config = described_class.new(File.binread(fixture_path("v7", "key-repeat-disabled.cfg"))).parse
      expect(config.flags_1 & 0x01).to eq(0)
    end

    it "parses haptic-feedback-off flags" do
      config = described_class.new(File.binread(fixture_path("v7", "haptic-feedback-off.cfg"))).parse
      expect(config.flags_1 & 0x08).to eq(0)
    end

    it "parses button-mode-keyboard flags" do
      config = described_class.new(File.binread(fixture_path("v7", "button-mode-keyboard.cfg"))).parse
      expect(config.flags_1 & 0x02).to eq(0x02)
    end

    it "parses nav-sensitivity-lowered flags" do
      config = described_class.new(File.binread(fixture_path("v7", "nav-sensitivity-lowered.cfg"))).parse
      expect(config.flags_2).to eq(0x00)
    end

    it "parses nav-invert-x-axis flags" do
      config = described_class.new(File.binread(fixture_path("v7", "nav-invert-x-axis.cfg"))).parse
      expect(config.flags_2 & 0x04).to eq(0x04)
    end

    it "parses nav-up-east flags" do
      config = described_class.new(File.binread(fixture_path("v7", "nav-up-east.cfg"))).parse
      expect(config.flags_2 & 0x03).to eq(0x01)
    end

    it "parses no-right-mouse-button dedicated buttons" do
      config = described_class.new(File.binread(fixture_path("v7", "no-right-mouse-button.cfg"))).parse
      expect(config.dedicated_buttons[0]).to eq(0x00)
    end

    it "parses no-t0-dedicated dedicated buttons" do
      config = described_class.new(File.binread(fixture_path("v7", "no-t0-dedicated.cfg"))).parse
      expect(config.dedicated_buttons[3]).to eq(0x00)
    end
  end

  describe "chord fixtures" do
    it "parses a keyboard chord" do
      config = described_class.new(File.binread(fixture_path("v7", "single-unmodified-key.cfg"))).parse
      kbd = config.chords.find { |c| c.type_name == :keyboard }
      expect(kbd.key_name).to eq("c")
    end

    it "parses a shifted chord" do
      config = described_class.new(File.binread(fixture_path("v7", "shifted-key.cfg"))).parse
      kbd = config.chords.find { |c| c.type_name == :keyboard }
      expect(kbd.modifier_names).to eq(["Shift"])
    end

    it "parses a modifier chord" do
      config = described_class.new(File.binread(fixture_path("v7", "modifier-key.cfg"))).parse
      kbd = config.chords.find { |c| c.type_name == :keyboard }
      expect(kbd.modifier_names).to eq(["Ctrl"])
      expect(kbd.key_name).to eq("c")
    end

    it "parses a multi-char chord" do
      config = described_class.new(File.binread(fixture_path("v7", "multi-char.cfg"))).parse
      mc = config.chords.find { |c| c.type_name == :multichar }
      expect(mc.string_keys.length).to eq(4)
    end

    it "parses a device function chord" do
      config = described_class.new(File.binread(fixture_path("v7", "cycle-config-chord.cfg"))).parse
      dev = config.chords.find { |c| c.device_function == :config_cycle }
      expect(dev).not_to be_nil
    end

    it "parses mini-button chords" do
      config = described_class.new(File.binread(fixture_path("v7", "mini-buttons.cfg"))).parse
      mini = config.chords.select { |c| c.bitmask & 0x00070000 != 0 }
      expect(mini.length).to eq(3)
    end

    it "parses a large config" do
      config = described_class.new(File.binread(fixture_path("v7", "large.cfg"))).parse
      expect(config.chord_count).to be > 100
    end
  end
end
