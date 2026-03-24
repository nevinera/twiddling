module Twiddling
  module Cli
    # twiddling read <file.cfg|file.tw7>
    #
    # Reads a config file and prints it as .tw7 text to stdout.
    # Accepts both .cfg (binary) and .tw7 (text) formats.
    class Read
      READABLE_EXTS = %w[.cfg .tw7].freeze

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        validate!
        V7::Tw7::Printer.new(config, io: @stdout).print
      end

      private

      def path = @argv[0]

      def validate!
        raise ExitException, "Usage: twiddling read <file>" if path.nil?
        raise ExitException, "File not found: #{path}" unless File.exist?(path)

        return if READABLE_EXTS.include?(File.extname(path))

        raise ExitException, "Unsupported file type: #{path} (expected .cfg or .tw7)"
      end

      def config
        @config ||= case File.extname(path)
        when ".cfg" then V7::Config.from_file(path)
        when ".tw7" then V7::Tw7::Parser.new(File.read(path)).parse
        end
      end
    end
  end
end
