module Twiddling
  module Cli
    class Help
      HELP_TEXT = <<~TEXT
        Usage: twiddling <subcommand> [args]

        Subcommands:
          help                       Show this help message
          read <file>                Read a .cfg or .tw7 file
          convert <input> <output>   Convert between .cfg and .tw7 formats
      TEXT

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @stdout = stdout
      end

      def run
        @stdout.puts HELP_TEXT
      end
    end
  end
end
