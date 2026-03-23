describe Twiddling::V7::StringTable do
  describe "reading from binary" do
    # "test" = t(0x17) e(0x08) s(0x16) t(0x17), each with modifier 0x0002
    let(:raw) do
      [0x0002, 0x0017, 0x0002, 0x0008, 0x0002, 0x0016, 0x0002, 0x0017, 0x0000, 0x0000].pack("v*")
    end

    subject(:table) { described_class.new(raw) }

    describe "#read_entry" do
      it "reads a string entry at offset 0" do
        keys = table.read_entry(0)
        expect(keys.length).to eq(4)
        expect(keys.map { |k| k[:hid_code] }).to eq([0x17, 0x08, 0x16, 0x17])
      end

      it "reads modifiers" do
        keys = table.read_entry(0)
        expect(keys.map { |k| k[:modifier] }).to eq([0x0002, 0x0002, 0x0002, 0x0002])
      end
    end

    describe "#entry_count" do
      it "counts terminated entries" do
        expect(table.entry_count).to eq(1)
      end
    end

    describe "#to_binary" do
      it "returns the raw data" do
        expect(table.to_binary).to eq(raw)
      end
    end
  end

  describe "with multiple entries" do
    # "ab" then "cd"
    let(:raw) do
      [
        0x0002, 0x0004, 0x0002, 0x0005, 0x0000, 0x0000,
        0x0002, 0x0006, 0x0002, 0x0007, 0x0000, 0x0000
      ].pack("v*")
    end

    subject(:table) { described_class.new(raw) }

    it "reads the first entry at offset 0" do
      keys = table.read_entry(0)
      expect(keys.map { |k| k[:hid_code] }).to eq([0x04, 0x05])
    end

    it "reads the second entry at the correct offset" do
      keys = table.read_entry(12)
      expect(keys.map { |k| k[:hid_code] }).to eq([0x06, 0x07])
    end

    it "counts both entries" do
      expect(table.entry_count).to eq(2)
    end
  end

  describe ".from_entries" do
    it "builds a string table from key arrays" do
      entries = [
        [{modifier: 0x0002, hid_code: 0x17}, {modifier: 0x0002, hid_code: 0x08}]
      ]
      table = described_class.from_entries(entries)
      keys = table.read_entry(0)
      expect(keys.map { |k| k[:hid_code] }).to eq([0x17, 0x08])
    end

    it "handles multiple entries" do
      entries = [
        [{modifier: 0x0002, hid_code: 0x04}],
        [{modifier: 0x0002, hid_code: 0x05}]
      ]
      table = described_class.from_entries(entries)
      expect(table.read_entry(0).map { |k| k[:hid_code] }).to eq([0x04])
      expect(table.read_entry(8).map { |k| k[:hid_code] }).to eq([0x05])
    end

    it "round-trips with to_binary" do
      entries = [
        [{modifier: 0x0002, hid_code: 0x17}, {modifier: 0x2002, hid_code: 0x08}]
      ]
      table = described_class.from_entries(entries)
      table2 = described_class.new(table.to_binary)
      expect(table2.read_entry(0)).to eq(entries[0])
    end
  end

  describe "from multi-char.cfg fixture" do
    let(:raw) { File.binread(fixture_path("v7", "multi-char.cfg"))[200..] }

    subject(:table) { described_class.new(raw) }

    it "decodes 'test'" do
      keys = table.read_entry(0)
      expect(keys.length).to eq(4)
      expect(keys.map { |k| k[:hid_code] }).to eq([0x17, 0x08, 0x16, 0x17])
    end
  end
end
