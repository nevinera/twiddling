module Twiddling
  module Cli
    # twiddling read <file.cfg|file.tw7>
    #
    # Reads a config file and prints it as .tw7 text to stdout.
    # Accepts both .cfg (binary) and .tw7 (text) formats.
    class Read
      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        raise ExitException, "Usage: twiddling read <file>" if path.nil?
        raise ExitException, "File not found: #{path}" unless File.exist?(path)

        V7::Tw7::Printer.new(config, io: @stdout).print
      end

      private

      def path
        @argv.first
      end

      def config
        @config ||= case File.extname(path)
        when ".cfg"
          V7::Config.from_file(path)
        when ".tw7"
          V7::Tw7::Parser.new(File.read(path)).parse
        else
          raise ExitException, "Unknown file format: #{path} (expected .cfg or .tw7)"
        end
      end
    end
  end
end
