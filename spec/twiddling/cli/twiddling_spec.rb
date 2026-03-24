describe Twiddling::Cli::Twiddling do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  subject(:cli) { described_class.new(argv: argv, stdout: stdout, stderr: stderr) }

  describe "read subcommand" do
    let(:argv) { ["read", fixture_path("v7", "single-unmodified-key.cfg")] }

    it "dispatches to Read" do
      cli.run
      expect(stdout.string).to include("1R: c")
    end
  end

  describe "with no subcommand" do
    let(:argv) { [] }

    it "prints help" do
      cli.run
      expect(stdout.string).to include("Usage: twiddling")
      expect(stdout.string).to include("read")
    end
  end

  describe "help subcommand" do
    let(:argv) { ["help"] }

    it "prints help" do
      cli.run
      expect(stdout.string).to include("Usage: twiddling")
    end
  end

  describe "with unknown subcommand" do
    let(:argv) { ["bogus"] }

    it "raises ExitException" do
      expect { cli.run }.to raise_error(Twiddling::Cli::ExitException, /Unknown subcommand/)
    end
  end
end
