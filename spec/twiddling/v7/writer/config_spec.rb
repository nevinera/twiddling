describe Twiddling::V7::Writer::Config do
  describe "binary round-trip" do
    Dir[fixture_path("v7", "*.cfg")].sort.each do |path|
      name = File.basename(path)

      it "round-trips #{name}" do
        original = File.binread(path)
        config = Twiddling::V7::Reader::Config.new(original).parse
        expect(described_class.new(config).to_binary).to eq(original)
      end
    end
  end
end
