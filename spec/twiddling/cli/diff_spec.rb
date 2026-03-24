describe Twiddling::Cli::Diff do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  subject(:cli) { described_class.new(argv: argv, stdout: stdout, stderr: stderr) }

  describe "identical files" do
    let(:argv) { [fixture_path("v7", "empty.cfg"), fixture_path("v7", "empty.cfg"), "--no-color"] }

    it "reports no differences" do
      cli.run
      expect(stdout.string).to include("No differences.")
    end
  end

  describe "added chords" do
    let(:argv) do
      [fixture_path("v7", "empty.cfg"), fixture_path("v7", "single-unmodified-key.cfg"), "--no-color"]
    end

    it "lists added chords" do
      cli.run
      expect(stdout.string).to include("Added:")
      expect(stdout.string).to include("1R: c")
    end

    it "does not list removed or changed" do
      cli.run
      expect(stdout.string).not_to include("Removed:")
      expect(stdout.string).not_to include("Changed:")
    end
  end

  describe "removed chords" do
    let(:argv) do
      [fixture_path("v7", "single-unmodified-key.cfg"), fixture_path("v7", "empty.cfg"), "--no-color"]
    end

    it "lists removed chords" do
      cli.run
      expect(stdout.string).to include("Removed:")
      expect(stdout.string).to include("1R: c")
    end
  end

  describe "settings changes" do
    let(:argv) do
      [fixture_path("v7", "empty.cfg"), fixture_path("v7", "idle-time-8m.cfg"), "--no-color"]
    end

    it "lists changed settings" do
      cli.run
      expect(stdout.string).to include("Settings:")
      expect(stdout.string).to include("idle_time: 600 -> 480")
    end
  end

  describe "color output" do
    let(:argv) do
      [fixture_path("v7", "empty.cfg"), fixture_path("v7", "single-unmodified-key.cfg")]
    end

    it "includes ANSI color codes" do
      cli.run
      expect(stdout.string).to include("\e[32m")
    end
  end

  describe "--no-color" do
    let(:argv) do
      [fixture_path("v7", "empty.cfg"), fixture_path("v7", "single-unmodified-key.cfg"), "--no-color"]
    end

    it "does not include ANSI color codes" do
      cli.run
      expect(stdout.string).not_to include("\e[")
    end
  end

  describe "with .tw7 files" do
    let(:argv) do
      [fixture_path("v7", "empty.tw7"), fixture_path("v7", "single-unmodified-key.tw7"), "--no-color"]
    end

    it "works the same way" do
      cli.run
      expect(stdout.string).to include("Added:")
      expect(stdout.string).to include("1R: c")
    end
  end

  describe "--help" do
    let(:argv) { ["--help"] }

    it "prints help to stdout" do
      cli.run
      expect(stdout.string).to include("Usage: twiddling diff")
    end
  end

  describe "with missing arguments" do
    let(:argv) { [fixture_path("v7", "empty.cfg")] }

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
end
