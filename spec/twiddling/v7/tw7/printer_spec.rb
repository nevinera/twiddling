describe Twiddling::V7::Tw7::Printer do
  let(:io) { StringIO.new }
  let(:config) { Twiddling::V7::Config.from_file(fixture_path("v7", fixture_name)) }

  subject(:output) do
    described_class.new(config, io: io).print
    io.string
  end

  describe "settings" do
    context "default settings" do
      let(:fixture_name) { "empty.cfg" }

      it "does not emit a settings section" do
        expect(output).not_to include("=====")
      end
    end

    context "non-default settings" do
      let(:fixture_name) { "idle-time-8m.cfg" }

      it "emits changed settings above a divider" do
        expect(output).to include("idle_time: 480")
        expect(output).to include("=====")
      end
    end

    context "large config with many non-default settings" do
      let(:fixture_name) { "large.cfg" }

      it "emits all changed settings" do
        expect(output).to include("key_repeat: false")
        expect(output).to include("haptic: false")
        expect(output).to include("t1_modifier: l_command")
      end
    end
  end

  describe "chord formatting" do
    context "keyboard chord" do
      let(:fixture_name) { "single-unmodified-key.cfg" }

      it "formats as button: key" do
        expect(output).to include("1R: c")
      end
    end

    context "shifted chord" do
      let(:fixture_name) { "shifted-key.cfg" }

      it "formats shifted symbols directly" do
        expect(output).to include("1R: @")
      end
    end

    context "modifier chord" do
      let(:fixture_name) { "modifier-key.cfg" }

      it "formats as modifier+key" do
        expect(output).to include("1R: ctrl+c")
      end
    end

    context "multi-char chord" do
      let(:fixture_name) { "multi-char.cfg" }

      it "formats as quoted string" do
        expect(output).to include('1R: "test"')
      end
    end

    context "device function chord" do
      let(:fixture_name) { "cycle-config-chord.cfg" }

      it "formats as function name" do
        expect(output).to include("1R: config_cycle")
      end
    end

    context "mini-button chords" do
      let(:fixture_name) { "mini-buttons.cfg" }

      it "formats mini-buttons as F0L/F0M/F0R" do
        expect(output).to include("0L: l")
        expect(output).to include("0M: m")
        expect(output).to include("0R: r")
      end
    end
  end

  describe "edge cases" do
    it "formats unknown chord types as hex" do
      result = Twiddling::V7::Tw7::EffectFormatter.format_effect(
        Twiddling::V7::Chord.new(bitmask: 0, modifier_type: 0x0099, keycode: 0)
      )
      expect(result).to eq("0x0099")
    end

    it "formats uppercase letters in multichar strings" do
      result = Twiddling::V7::Tw7::EffectFormatter.string_key_to_char(
        {modifier: 0x2002, hid_code: 0x04}
      )
      expect(result).to eq("A")
    end
  end

  describe "grouping" do
    let(:fixture_name) { "large.cfg" }

    it "groups chords under thumb buttons" do
      expect(output).to include("T2::")
      expect(output).to include("T4::")
    end

    it "indents grouped chords" do
      lines = output.lines
      t2_idx = lines.index { |l| l.strip == "T2::" }
      expect(lines[t2_idx + 1]).to match(/^  \S/)
    end

    it "does not group single-chord thumb combos" do
      expect(output).to include("T14 4R: speed_cycle")
      expect(output).not_to include("T14::")
    end

    it "leaves no-thumb chords ungrouped" do
      expect(output).to include("1R: backspace")
    end

    it "groups mouse-mode chords under [MOUSEMODE]" do
      expect(output).to include("[MOUSEMODE]::")
      expect(output).to include("  1R: left_click")
    end

    it "preserves thumb buttons in mouse-mode chords" do
      expect(output).to include("  T23: mouse_toggle")
    end

    it "places [MOUSEMODE] group last" do
      lines = output.lines.map(&:rstrip)
      mousemode_idx = lines.index { |l| l == "[MOUSEMODE]::" }
      t4_idx = lines.index { |l| l == "T4::" }
      expect(mousemode_idx).to be > t4_idx
    end
  end
end
