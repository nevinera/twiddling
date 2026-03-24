module Twiddling
  module Cli
    # twiddling read <file.cfg|file.tw7>
    #
    # Reads a config file and prints it as .tw7 text to stdout.
    # Accepts both .cfg (binary) and .tw7 (text) formats.
    class Read
      READABLE_EXTS = %w[.cfg .tw7].freeze

      HELP_TEXT = <<~TEXT
        Usage: twiddling read <file>

        Reads a .cfg or .tw7 config file and prints it as .tw7 text
        to stdout.

        Examples:
          twiddling read my_config.cfg
          twiddling read layout.tw7
      TEXT

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        return @stdout.puts(HELP_TEXT) if help?
        validate!
        V7::Tw7::Printer.new(config, io: @stdout).print
      end

      private

      def path = @argv[0]

      def help? = @argv.include?("-h") || @argv.include?("--help")

      def validate!
        raise ExitException, HELP_TEXT if path.nil?
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
