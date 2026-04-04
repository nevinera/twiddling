describe Twiddling::V7::Tw7::Structurer do
  subject(:data) { described_class.new(text).structure }

  describe "#structure" do
    it "returns a ConfigData" do
      expect(described_class.new("").structure)
        .to be_a(Twiddling::V7::Tw7::ConfigData)
    end
  end

  describe "settings lines" do
    let(:text) { "idle_time: 480\nhaptic: false\n=====\n" }

    it "builds SettingsLine objects with correct line numbers" do
      expect(data.settings_lines.map(&:line_number)).to eq([1, 2])
    end

    it "strips leading/trailing whitespace from line text" do
      expect(data.settings_lines.map(&:line_text)).to eq(["idle_time: 480", "haptic: false"])
    end

    it "excludes blank lines" do
      data = described_class.new("\nidle_time: 480\n\n=====\n").structure
      expect(data.settings_lines.length).to eq(1)
    end

    context "with no divider" do
      let(:text) { "1R: c\n" }

      it "produces no settings lines" do
        expect(data.settings_lines).to be_empty
      end
    end
  end

  describe "chord tree" do
    context "flat chords" do
      let(:text) { "1R: c\n1M: space\n" }

      it "builds ChordLine objects" do
        expect(data.chord_lines).to all(be_a(Twiddling::V7::Tw7::ChordLine))
      end

      it "assigns correct line numbers" do
        expect(data.chord_lines.map(&:line_number)).to eq([1, 2])
      end
    end

    context "single-level scope" do
      let(:text) { "T4::\n  1R: c\n  1M: d\n" }

      it "builds a ChordScopeLine at the top level" do
        expect(data.chord_lines.length).to eq(1)
        expect(data.chord_lines.first).to be_a(Twiddling::V7::Tw7::ChordScopeLine)
      end

      it "nests chord lines as children" do
        expect(data.chord_lines.first.children.length).to eq(2)
        expect(data.chord_lines.first.children).to all(be_a(Twiddling::V7::Tw7::ChordLine))
      end
    end

    context "nested scopes" do
      let(:text) { "1M::\n  2M: y\n  2M::\n    3M: n\n  4M: z\n" }

      it "builds a single top-level scope" do
        expect(data.chord_lines.length).to eq(1)
      end

      it "nests the inner scope and sibling chords correctly" do
        outer = data.chord_lines.first
        expect(outer.children.length).to eq(3)
        expect(outer.children[0]).to be_a(Twiddling::V7::Tw7::ChordLine)
        expect(outer.children[1]).to be_a(Twiddling::V7::Tw7::ChordScopeLine)
        expect(outer.children[2]).to be_a(Twiddling::V7::Tw7::ChordLine)
      end

      it "nests the deepest chord under the inner scope" do
        inner = data.chord_lines.first.children[1]
        expect(inner.children.length).to eq(1)
        expect(inner.children.first.line_text).to eq("3M: n")
      end
    end

    context "scope followed by non-indented chord" do
      let(:text) { "T4::\n  1R: c\n1M: d\n" }

      it "puts the non-indented chord at the top level" do
        expect(data.chord_lines.length).to eq(2)
        expect(data.chord_lines.last).to be_a(Twiddling::V7::Tw7::ChordLine)
        expect(data.chord_lines.last.line_text).to eq("1M: d")
      end
    end

    context "comments" do
      let(:text) { "# comment\n1R: c # inline\n" }

      it "strips full-line comments" do
        expect(data.chord_lines.length).to eq(1)
      end

      it "strips inline comments" do
        expect(data.chord_lines.first.line_text).to eq("1R: c")
      end
    end
  end
end
