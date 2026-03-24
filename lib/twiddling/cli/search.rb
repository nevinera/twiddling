require "optparse"

module Twiddling
  module Cli
    # twiddling search <file> [options]
    #
    # Searches for chords matching all supplied filters.
    #   --chord BUTTONS   Exact button match (low bits only)
    #   --button BUTTON   Chord includes this button (repeatable)
    #   --result EFFECT   Chord produces this output
    class Search
      READABLE_EXTS = %w[.cfg .tw7].freeze

      HELP_TEXT = <<~TEXT
        Usage: twiddling search <file> [filters]

        Searches for chords matching all supplied filters.

        Filters:
          --chord BUTTONS   Exact button combination match
          --button BUTTON   Includes this button (repeatable)
          --result EFFECT   Produces this output

        Examples:
          twiddling search my.cfg --chord "T1 1L"
          twiddling search my.tw7 --result "@"
          twiddling search my.cfg --button T4 --button 0M
      TEXT

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
      end

      def run
        return @stdout.puts(HELP_TEXT) if help?
        validate!
        matches = apply_filters
        if matches.empty?
          @stderr.puts "No matching chords found."
        else
          print_matches(matches)
        end
      end

      def options
        @options ||= parse_options
      end

      private

      def parse_options
        opts = {buttons: []}
        remaining = option_parser(opts).parse(@argv.dup)
        opts[:path] = remaining.shift
        opts
      end

      def option_parser(opts)
        OptionParser.new do |parser|
          parser.on("--chord BUTTONS", "Exact chord match") { |c| opts[:chord] = c }
          parser.on("--button BUTTON", "Includes button (repeatable)") { |b| opts[:buttons] << b }
          parser.on("--result EFFECT", "Produces this output") { |r| opts[:result] = r }
        end
      end

      def path = options[:path]

      def help? = @argv.include?("-h") || @argv.include?("--help")

      def validate!
        raise ExitException, HELP_TEXT if path.nil?
        raise ExitException, "File not found: #{path}" unless File.exist?(path)
        validate_ext!
        raise ExitException, "No search criteria specified" unless any_filters?
      end

      def validate_ext!
        return if READABLE_EXTS.include?(File.extname(path))

        raise ExitException, "Unsupported file type: #{path} (expected .cfg or .tw7)"
      end

      def any_filters?
        options[:chord] || options[:buttons].any? || options[:result]
      end

      def config
        @config ||= case File.extname(path)
        when ".cfg" then V7::Config.from_file(path)
        when ".tw7" then V7::Tw7::Parser.new(File.read(path)).parse
        end
      end

      def apply_filters
        results = config.chords
        results = filter_by_chord(results) if options[:chord]
        results = filter_by_buttons(results) if options[:buttons].any?
        results = filter_by_result(results) if options[:result]
        results
      end

      def filter_by_chord(chords)
        target = V7::Tw7::ButtonParser.parse(options[:chord])
        chords.select { |c| (c.bitmask & 0x7FFFF) == target }
      end

      def filter_by_buttons(chords)
        bits = options[:buttons].map { |b| V7::Tw7::ButtonParser.parse(b) }
        chords.select { |c| bits.all? { |b| c.bitmask & b == b } }
      end

      def filter_by_result(chords)
        target = options[:result]
        chords.select { |c| V7::Tw7::EffectFormatter.format_effect(c) == target }
      end

      def print_matches(chords)
        chords.each do |chord|
          buttons = V7::Tw7::ButtonFormatter.format(
            chord.bitmask & ~V7::ChordConstants::MOUSE_MODE_FLAG
          )
          effect = V7::Tw7::EffectFormatter.format_effect(chord)
          prefix = chord.mouse_mode? ? "[MOUSEMODE] " : ""
          @stdout.puts "#{prefix}#{buttons}: #{effect}"
        end
      end
    end
  end
end
