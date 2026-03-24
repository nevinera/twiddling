describe Twiddling::Cli::Search do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  subject(:cli) { described_class.new(argv: argv, stdout: stdout, stderr: stderr) }

  let(:cfg) { fixture_path("v7", "large.cfg") }

  describe "--chord (exact match)" do
    let(:argv) { [cfg, "--chord", "1R"] }

    it "finds chords with exactly those buttons" do
      cli.run
      expect(stdout.string).to include("1R: backspace")
    end

    it "excludes chords with additional buttons" do
      cli.run
      lines = stdout.string.lines
      expect(lines.none? { |l| l.include?("1R 2R") }).to be true
    end
  end

  describe "--button (includes)" do
    let(:argv) { [cfg, "--button", "T4", "--button", "1R"] }

    it "finds chords including all specified buttons" do
      cli.run
      expect(stdout.string).to include("ctrl+y")
    end

    it "only returns chords containing both buttons" do
      cli.run
      stdout.string.lines.each do |line|
        expect(line).to include("T4") if line.include?(": ")
      end
    end
  end

  describe "--result (output match)" do
    let(:argv) { [cfg, "--result", "ctrl+c"] }

    it "finds chords producing that output" do
      cli.run
      expect(stdout.string).to include("ctrl+c")
    end
  end

  describe "combined filters" do
    let(:argv) { [cfg, "--button", "T4", "--result", "up"] }

    it "applies all filters" do
      cli.run
      lines = stdout.string.lines.map(&:strip).reject(&:empty?)
      expect(lines.length).to eq(1)
      expect(lines[0]).to include("T4")
      expect(lines[0]).to include("up")
    end
  end

  describe "no matches" do
    let(:argv) { [cfg, "--chord", "T1234"] }

    it "prints a message to stderr" do
      cli.run
      expect(stderr.string).to include("No matching chords")
    end
  end

  describe "with a .tw7 file" do
    let(:argv) { [fixture_path("v7", "large.tw7"), "--chord", "1R"] }

    it "works the same way" do
      cli.run
      expect(stdout.string).to include("1R: backspace")
    end
  end

  describe "--help" do
    let(:argv) { ["--help"] }

    it "prints help to stdout" do
      cli.run
      expect(stdout.string).to include("Usage: twiddling search")
    end
  end

  describe "with no filters" do
    let(:argv) { [cfg] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /No search criteria/)
    end
  end

  describe "with no arguments" do
    let(:argv) { [] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Usage/)
    end
  end
end
