module Twiddling
  module Cli
    # twiddling convert <input> <output>
    #
    # Converts between .cfg and .tw7 formats. The direction is
    # determined by the file extensions.
    class Convert
      VALID_EXTS = %w[.cfg .tw7].freeze

      HELP_TEXT = <<~TEXT
        Usage: twiddling convert <input> <output>

        Converts between .cfg (binary) and .tw7 (text) formats.
        The direction is determined by the file extensions.

        Examples:
          twiddling convert my_config.cfg layout.tw7
          twiddling convert layout.tw7 my_config.cfg
      TEXT

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        return @stdout.puts(HELP_TEXT) if help?
        validate!
        write_output
      end

      private

      def input_path = @argv[0]

      def output_path = @argv[1]

      def help? = @argv.include?("-h") || @argv.include?("--help")

      def validate!
        raise ExitException, HELP_TEXT unless input_path && output_path
        raise ExitException, "File not found: #{input_path}" unless File.exist?(input_path)
        validate_ext!(input_path)
        validate_ext!(output_path)
      end

      def validate_ext!(file)
        return if VALID_EXTS.include?(File.extname(file))

        raise ExitException, "Unsupported file type: #{file} (expected .cfg or .tw7)"
      end

      def config
        @config ||= case File.extname(input_path)
        when ".cfg" then V7::Config.from_file(input_path)
        when ".tw7" then V7::Tw7::Parser.new(File.read(input_path)).parse
        end
      end

      def write_output
        case File.extname(output_path)
        when ".cfg" then config.write(output_path)
        when ".tw7"
          File.open(output_path, "w") { |f| V7::Tw7::Printer.new(config, io: f).print }
        end
      end
    end
  end
end
