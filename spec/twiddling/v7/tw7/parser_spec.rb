describe Twiddling::V7::Tw7::Parser do
  describe "tw7 round-trip" do
    Dir[fixture_path("v7", "*.tw7")].sort.each do |path|
      name = File.basename(path)

      it "round-trips #{name}" do
        text = File.read(path)
        config = described_class.new(text).parse
        io = StringIO.new
        Twiddling::V7::Tw7::Printer.new(config, io: io).print
        expect(io.string).to eq(text)
      end
    end
  end

  describe "settings parsing" do
    it "parses idle_time" do
      config = described_class.new("idle_time: 480\n=====\n").parse
      expect(config.idle_time).to eq(480)
    end

    it "parses flags" do
      config = described_class.new("key_repeat: false\nhaptic: false\n=====\n").parse
      expect(config.flags_1 & 0x01).to eq(0)
      expect(config.flags_1 & 0x08).to eq(0)
    end

    it "parses thumb modifiers" do
      config = described_class.new("t1_modifier: l_command\n=====\n").parse
      expect(config.thumb_modifiers[0]).to eq(4)
    end

    it "parses dedicated buttons" do
      config = described_class.new("f0l_dedicated: none\n=====\n").parse
      expect(config.dedicated_buttons[0]).to eq(0x00)
    end

    it "uses defaults for unspecified settings" do
      config = described_class.new("1R: c").parse
      expect(config.idle_time).to eq(600)
      expect(config.flags_1 & 0x01).to eq(0x01)
    end
  end

  describe "chord parsing" do
    it "parses a keyboard chord" do
      config = described_class.new("1R: c").parse
      chord = config.chords.first
      expect(chord.key_name).to eq("c")
    end

    it "parses a shifted symbol" do
      config = described_class.new("1R: @").parse
      chord = config.chords.first
      expect(chord.modifier_names).to eq(["Shift"])
    end

    it "parses a modifier+key" do
      config = described_class.new("1R: ctrl+c").parse
      chord = config.chords.first
      expect(chord.modifier_names).to eq(["Ctrl"])
      expect(chord.key_name).to eq("c")
    end

    it "parses a multi-char string" do
      config = described_class.new('1R: "test"').parse
      chord = config.chords.first
      expect(chord.type_name).to eq(:multichar)
      expect(chord.string_keys.length).to eq(4)
    end

    it "parses a single-char quoted string as keyboard chord" do
      config = described_class.new('1R: "#"').parse
      chord = config.chords.first
      expect(chord.type_name).to eq(:keyboard)
    end

    it "parses a device function" do
      config = described_class.new("1R: speed_cycle").parse
      chord = config.chords.first
      expect(chord.device_function).to eq(:speed_cycle)
    end

    it "parses hex keycodes" do
      config = described_class.new("1R: 0x0047").parse
      chord = config.chords.first
      expect(chord.keycode).to eq(0x47)
    end

    it "parses + as a shifted symbol, not a modifier" do
      config = described_class.new("1R: +").parse
      chord = config.chords.first
      expect(chord.modifier_names).to eq(["Shift"])
      expect(chord.key_name).to eq("=")
    end
  end

  describe "button parsing" do
    it "accepts F prefix" do
      config = described_class.new("F1R: c").parse
      expect(config.chords.first.bitmask & 0xFFFF).to eq(0x02)
    end

    it "accepts no F prefix" do
      config = described_class.new("1R: c").parse
      expect(config.chords.first.bitmask & 0xFFFF).to eq(0x02)
    end

    it "is case-insensitive" do
      config = described_class.new("t4 f1r: c").parse
      chord = config.chords.first
      expect(chord.bitmask & 0x1002).to eq(0x1002)
    end

    it "allows no spaces between finger tokens" do
      config = described_class.new("1R2M: c").parse
      chord = config.chords.first
      expect(chord.bitmask & 0x0042).to eq(0x0042)
    end

    it "requires space or F between thumb and finger" do
      config = described_class.new("T4 1R: c").parse
      chord = config.chords.first
      expect(chord.bitmask & 0x1002).to eq(0x1002)
    end
  end

  describe "grouping" do
    it "unions scope buttons with indented chords" do
      tw7 = "T4::\n  1R: c\n  1M: d\n"
      config = described_class.new(tw7).parse
      expect(config.chords.all? { |c| c.bitmask & 0x1000 != 0 }).to be true
    end

    it "handles [MOUSEMODE] scope" do
      tw7 = "[MOUSEMODE]::\n  1R: left_click\n"
      config = described_class.new(tw7).parse
      expect(config.chords.first.mouse_mode?).to be true
    end

    it "resets scope on non-indented lines" do
      tw7 = "T4::\n  1R: c\n1M: d\n"
      config = described_class.new(tw7).parse
      d_chord = config.chords.find { |c| c.key_name == "d" }
      expect(d_chord.bitmask & 0x1000).to eq(0)
    end
  end

  describe "error handling" do
    it "reports line numbers on parse errors" do
      expect { described_class.new("1R: zzz").parse }
        .to raise_error(ArgumentError, /Line 1/)
    end
  end

  describe "comments" do
    it "strips inline comments" do
      config = described_class.new("1R: c # a comment").parse
      expect(config.chords.first.key_name).to eq("c")
    end

    it "strips full-line comments" do
      config = described_class.new("# comment\n1R: c").parse
      expect(config.chords.length).to eq(1)
    end

    it "does not strip # inside quotes" do
      config = described_class.new('1R: "#"').parse
      chord = config.chords.first
      expect(chord.modifier_names).to eq(["Shift"])
      expect(chord.key_name).to eq("3")
    end
  end
end
