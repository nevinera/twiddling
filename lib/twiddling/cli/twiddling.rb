module Twiddling
  module Cli
    class Twiddling
      SUBCOMMANDS = {
        "read" => :Read
      }.freeze

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        subcommand = @argv.shift
        raise ExitException, usage unless subcommand
        klass = resolve(subcommand)
        klass.new(argv: @argv, stdout: @stdout, stderr: @stderr).run
      end

      private

      def resolve(name)
        const = SUBCOMMANDS[name]
        raise ExitException, "Unknown subcommand: #{name}\n#{usage}" unless const
        Cli.const_get(const)
      end

      def usage
        "Usage: twiddling <subcommand> [options]\n\nSubcommands: #{SUBCOMMANDS.keys.join(", ")}"
      end
    end
  end
end
