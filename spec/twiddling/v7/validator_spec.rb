describe Twiddling::V7::Validator do
  let(:config) { Twiddling::V7::Config.from_file(fixture_path("v7", "empty.cfg")) }

  describe "#validate" do
    it "returns an empty array for a valid config" do
      expect(described_class.new(config).validate).to be_empty
    end

    context "wrong format version" do
      let(:bad_config) { config.send(:with_no_validate, format_version: 5) }

      it "reports the error" do
        errors = described_class.new(bad_config).validate
        expect(errors.length).to eq(1)
        expect(errors[0].field).to eq(:format_version)
        expect(errors[0].message).to include("expected 7")
      end
    end

    context "unsorted chords" do
      let(:bad_config) do
        chord_a = Twiddling::V7::Chord.new(bitmask: 0x10, modifier_type: 0x0002, keycode: 0x04)
        chord_b = Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x0002, keycode: 0x05)
        config.send(:with_no_validate, chords: [chord_a, chord_b])
      end

      it "reports the error" do
        errors = described_class.new(bad_config).validate
        expect(errors.any? { |e| e.field == :chords && e.message.include?("not sorted") }).to be true
      end
    end

    context "chord count overflow" do
      let(:bad_config) do
        chords = (0..0xFFFF).map { |i| Twiddling::V7::Chord.new(bitmask: i, modifier_type: 0x0002, keycode: 0x04) }
        config.send(:with_no_validate, chords: chords + [chords.first])
      end

      it "reports the error" do
        errors = described_class.new(bad_config).validate
        expect(errors.any? { |e| e.field == :chord_count }).to be true
      end
    end

    context "duplicate bitmasks" do
      let(:bad_config) do
        chord = Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x0002, keycode: 0x04)
        dupe = Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x0002, keycode: 0x05)
        config.send(:with_no_validate, chords: [chord, dupe])
      end

      it "reports the error" do
        errors = described_class.new(bad_config).validate
        expect(errors.any? { |e| e.field == :chords && e.message.include?("duplicate") }).to be true
      end
    end

    context "multi-char chord with no string keys" do
      let(:bad_config) do
        chord = Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x0007, keycode: 0)
        config.send(:with_no_validate, chords: [chord])
      end

      it "reports the error" do
        errors = described_class.new(bad_config).validate
        expect(errors.any? { |e| e.message.include?("no string keys") }).to be true
      end
    end

    context "multiple errors" do
      let(:bad_config) do
        config.send(:with_no_validate, format_version: 5, chords: [
          Twiddling::V7::Chord.new(bitmask: 0x10, modifier_type: 0x0002, keycode: 0x04),
          Twiddling::V7::Chord.new(bitmask: 0x02, modifier_type: 0x0002, keycode: 0x05)
        ])
      end

      it "returns all errors" do
        errors = described_class.new(bad_config).validate
        expect(errors.length).to be >= 2
      end
    end
  end

  describe "#validate!" do
    it "does not raise for valid configs" do
      expect { described_class.new(config).validate! }.not_to raise_error
    end

    it "raises ValidationError for invalid configs" do
      bad = config.send(:with_no_validate, format_version: 5)
      expect { described_class.new(bad).validate! }
        .to raise_error(Twiddling::V7::Validator::ValidationError, /format_version/)
    end
  end

  describe "Error struct" do
    it "formats as string" do
      error = described_class::Error.new(field: :chords, message: "broken")
      expect(error.to_s).to eq("chords: broken")
    end
  end

  describe "all fixtures pass validation" do
    Dir[fixture_path("v7", "*.cfg")].sort.each do |path|
      name = File.basename(path)

      it "validates #{name}" do
        config = Twiddling::V7::Config.from_file(path)
        expect(described_class.new(config).validate).to be_empty
      end
    end
  end
end
