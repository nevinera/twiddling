describe Twiddling::Cli::Read do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  subject(:cli) { described_class.new(argv: argv, stdout: stdout, stderr: stderr) }

  describe "reading a .cfg file" do
    let(:argv) { [fixture_path("v7", "single-unmodified-key.cfg")] }

    it "prints tw7 format to stdout" do
      cli.run
      expect(stdout.string).to include("1R: c")
    end
  end

  describe "reading a .tw7 file" do
    let(:argv) { [fixture_path("v7", "single-unmodified-key.tw7")] }

    it "prints tw7 format to stdout" do
      cli.run
      expect(stdout.string).to include("1R: c")
    end
  end

  describe "--help" do
    let(:argv) { ["--help"] }

    it "prints help to stdout" do
      cli.run
      expect(stdout.string).to include("Usage: twiddling read")
    end
  end

  describe "-h" do
    let(:argv) { ["-h"] }

    it "prints help to stdout" do
      cli.run
      expect(stdout.string).to include("Usage: twiddling read")
    end
  end

  describe "with no arguments" do
    let(:argv) { [] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Usage/)
    end
  end

  describe "with a nonexistent file" do
    let(:argv) { ["nonexistent.cfg"] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /File not found/)
    end
  end

  describe "with an unsupported extension" do
    let(:argv) { [fixture_path("v7", "README.md")] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Unsupported file type/)
    end
  end
end
