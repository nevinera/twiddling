describe Twiddling::V7::StringTable do
  describe "#entry_at_offset" do
    let(:entry1) { Twiddling::V7::StringTableEntry.new(keys: [{modifier: 0x0002, hid_code: 0x04}], byte_offset: 0) }
    let(:entry2) { Twiddling::V7::StringTableEntry.new(keys: [{modifier: 0x0002, hid_code: 0x05}], byte_offset: 8) }

    subject(:table) { described_class.new([entry1, entry2]) }

    it "looks up entries by byte offset" do
      expect(table.entry_at_offset(0)).to eq(entry1)
      expect(table.entry_at_offset(8)).to eq(entry2)
    end

    it "returns nil for unknown offsets" do
      expect(table.entry_at_offset(99)).to be_nil
    end
  end
end

describe Twiddling::V7::StringTableEntry do
  subject(:entry) do
    described_class.new(
      keys: [{modifier: 0x0002, hid_code: 0x17}, {modifier: 0x0002, hid_code: 0x08}],
      byte_offset: 12
    )
  end

  it "exposes keys and byte_offset" do
    expect(entry.keys.length).to eq(2)
    expect(entry.byte_offset).to eq(12)
  end

  it "calculates byte_size" do
    expect(entry.byte_size).to eq(12)
  end
end

describe Twiddling::V7::Reader::StringTable do
  describe "#parse" do
    context "single entry (test)" do
      let(:raw) do
        [0x0002, 0x0017, 0x0002, 0x0008, 0x0002, 0x0016, 0x0002, 0x0017, 0x0000, 0x0000].pack("v*")
      end

      subject(:table) { described_class.new(raw).parse }

      it "returns a StringTable" do
        expect(table).to be_a(Twiddling::V7::StringTable)
      end

      it "parses one entry" do
        expect(table.entries.length).to eq(1)
      end

      it "decodes the keys" do
        expect(table.entries[0].keys.map { |k| k[:hid_code] }).to eq([0x17, 0x08, 0x16, 0x17])
      end

      it "sets byte_offset to 0" do
        expect(table.entries[0].byte_offset).to eq(0)
      end
    end

    context "two entries (ab then cd)" do
      let(:raw) do
        [
          0x0002, 0x0004, 0x0002, 0x0005, 0x0000, 0x0000,
          0x0002, 0x0006, 0x0002, 0x0007, 0x0000, 0x0000
        ].pack("v*")
      end

      subject(:table) { described_class.new(raw).parse }

      it "parses two entries" do
        expect(table.entries.length).to eq(2)
      end

      it "sets correct byte offsets" do
        expect(table.entries[0].byte_offset).to eq(0)
        expect(table.entries[1].byte_offset).to eq(12)
      end

      it "supports lookup by offset" do
        entry = table.entry_at_offset(12)
        expect(entry.keys.map { |k| k[:hid_code] }).to eq([0x06, 0x07])
      end
    end

    context "from multi-char.cfg fixture" do
      let(:raw) { File.binread(fixture_path("v7", "multi-char.cfg"))[200..] }

      subject(:table) { described_class.new(raw).parse }

      it "decodes 'test'" do
        entry = table.entry_at_offset(0)
        expect(entry.keys.length).to eq(4)
        expect(entry.keys.map { |k| k[:hid_code] }).to eq([0x17, 0x08, 0x16, 0x17])
      end
    end
  end
end

describe Twiddling::V7::Writer::StringTable do
  describe "#to_binary" do
    let(:entry) do
      Twiddling::V7::StringTableEntry.new(
        keys: [{modifier: 0x0002, hid_code: 0x17}, {modifier: 0x0002, hid_code: 0x08}],
        byte_offset: 0
      )
    end

    subject(:writer) { described_class.new(Twiddling::V7::StringTable.new([entry])) }

    it "encodes entries with null terminators" do
      expected = [0x0002, 0x0017, 0x0002, 0x0008, 0x0000, 0x0000].pack("v*")
      expect(writer.to_binary).to eq(expected)
    end
  end

  describe "#to_binary with multiple entries" do
    let(:entry1) { Twiddling::V7::StringTableEntry.new(keys: [{modifier: 0x0002, hid_code: 0x04}], byte_offset: 0) }
    let(:entry2) { Twiddling::V7::StringTableEntry.new(keys: [{modifier: 0x0002, hid_code: 0x05}], byte_offset: 8) }

    subject(:writer) { described_class.new(Twiddling::V7::StringTable.new([entry1, entry2])) }

    it "concatenates entries" do
      expected = [
        0x0002, 0x0004, 0x0000, 0x0000,
        0x0002, 0x0005, 0x0000, 0x0000
      ].pack("v*")
      expect(writer.to_binary).to eq(expected)
    end
  end

  describe "round-trip with Reader::StringTable" do
    let(:raw) do
      [
        0x0002, 0x0004, 0x0002, 0x0005, 0x0000, 0x0000,
        0x0002, 0x0006, 0x0002, 0x0007, 0x0000, 0x0000
      ].pack("v*")
    end

    it "round-trips binary data" do
      table = Twiddling::V7::Reader::StringTable.new(raw).parse
      expect(described_class.new(table).to_binary).to eq(raw)
    end
  end
end
