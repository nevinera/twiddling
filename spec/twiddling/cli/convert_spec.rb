describe Twiddling::Cli::Convert do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  subject(:cli) { described_class.new(argv: argv, stdout: stdout, stderr: stderr) }

  describe "cfg to tw7" do
    let(:output) { tmp_path("convert_out.tw7") }
    let(:argv) { [fixture_path("v7", "single-unmodified-key.cfg"), output] }

    after { FileUtils.rm_f(output) }

    it "writes tw7 format" do
      cli.run
      expect(File.read(output)).to include("1R: c")
    end
  end

  describe "tw7 to cfg" do
    let(:output) { tmp_path("convert_out.cfg") }
    let(:argv) { [fixture_path("v7", "single-unmodified-key.tw7"), output] }

    after { FileUtils.rm_f(output) }

    it "writes a parseable binary config" do
      cli.run
      config = Twiddling::V7::Config.from_file(output)
      kbd = config.chords.find { |c| c.type_name == :keyboard }
      expect(kbd.key_name).to eq("c")
    end
  end

  describe "with missing arguments" do
    let(:argv) { [fixture_path("v7", "single-unmodified-key.cfg")] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Usage/)
    end
  end

  describe "with no arguments" do
    let(:argv) { [] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Usage/)
    end
  end

  describe "with unsupported input extension" do
    let(:argv) { [fixture_path("v7", "README.md"), tmp_path("out.tw7")] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Unsupported file type/)
    end
  end

  describe "with unsupported output extension" do
    let(:argv) { [fixture_path("v7", "single-unmodified-key.cfg"), tmp_path("out.txt")] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Unsupported file type/)
    end
  end
end
