module Twiddling
  module Cli
    # twiddling read <file.cfg|file.tw7> [output.tw7]
    #
    # Reads a config file and prints it as .tw7 text.
    # Accepts both .cfg (binary) and .tw7 (text) formats.
    # Writes to output file if given, otherwise stdout.
    class Read
      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        validate!
        print_config
      end

      READABLE_EXTS = %w[.cfg .tw7].freeze
      WRITABLE_EXTS = %w[.tw7].freeze

      def validate!
        raise ExitException, "Usage: twiddling read <file> [output.tw7]" if path.nil?
        raise ExitException, "File not found: #{path}" unless File.exist?(path)
        validate_ext!(path, READABLE_EXTS)
        validate_ext!(output_path, WRITABLE_EXTS) if output_path
      end

      def validate_ext!(file, allowed)
        return if allowed.include?(File.extname(file))

        raise ExitException, "Unsupported file type: #{file} (expected #{allowed.join(" or ")})"
      end

      def print_config
        if output_path
          File.open(output_path, "w") { |f| V7::Tw7::Printer.new(config, io: f).print }
        else
          V7::Tw7::Printer.new(config, io: @stdout).print
        end
      end

      private

      def path = @argv[0]

      def output_path = @argv[1]

      def config
        @config ||= load_config(path)
      end

      def load_config(file)
        case File.extname(file)
        when ".cfg" then V7::Config.from_file(file)
        when ".tw7" then V7::Tw7::Parser.new(File.read(file)).parse
        else
          raise ExitException, "Unknown file format: #{file} (expected .cfg or .tw7)"
        end
      end
    end
  end
end
