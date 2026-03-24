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
        expect(output).to include("F1R: c")
      end
    end

    context "shifted chord" do
      let(:fixture_name) { "shifted-key.cfg" }

      it "formats shifted symbols directly" do
        expect(output).to include("F1R: @")
      end
    end

    context "modifier chord" do
      let(:fixture_name) { "modifier-key.cfg" }

      it "formats as modifier+key" do
        expect(output).to include("F1R: ctrl+c")
      end
    end

    context "multi-char chord" do
      let(:fixture_name) { "multi-char.cfg" }

      it "formats as quoted string" do
        expect(output).to include('F1R: "test"')
      end
    end

    context "device function chord" do
      let(:fixture_name) { "cycle-config-chord.cfg" }

      it "formats as function name" do
        expect(output).to include("F1R: config_cycle")
      end
    end

    context "mini-button chords" do
      let(:fixture_name) { "mini-buttons.cfg" }

      it "formats mini-buttons as F0L/F0M/F0R" do
        expect(output).to include("F0L: l")
        expect(output).to include("F0M: m")
        expect(output).to include("F0R: r")
      end
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
      expect(output).to include("T14 F4R: speed_cycle")
      expect(output).not_to include("T14::")
    end

    it "leaves no-thumb chords ungrouped" do
      expect(output).to include("F1R: backspace")
    end
  end
end
