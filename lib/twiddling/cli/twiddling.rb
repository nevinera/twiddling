module Twiddling
  module Cli
    class Twiddling
      SUBCOMMANDS = {
        "read" => :Read,
        "convert" => :Convert,
        "search" => :Search,
        "diff" => :Diff,
        "help" => :Help
      }.freeze

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        subcommand = @argv.shift || "help"
        klass = resolve(subcommand)
        klass.new(argv: @argv, stdout: @stdout, stderr: @stderr).run
      end

      private

      def resolve(name)
        const = SUBCOMMANDS[name]
        raise ExitException, "Unknown subcommand: #{name}\n\n#{Help::HELP_TEXT}" unless const
        Cli.const_get(const)
      end
    end
  end
end
