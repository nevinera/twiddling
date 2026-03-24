require "optparse"

module Twiddling
  module Cli
    # twiddling diff <file_a> <file_b> [--no-color]
    #
    # Shows differences between two configs: settings changes,
    # removed chords, changed chords, and added chords.
    class Diff
      READABLE_EXTS = %w[.cfg .tw7].freeze

      HELP_TEXT = <<~TEXT
        Usage: twiddling diff <file_a> <file_b> [--no-color]

        Shows differences between two Twiddler configs.

        Prints changed settings, then removed, changed, and added
        chords. Output is colorized by default (red=removed,
        yellow=changed, green=added).

        Examples:
          twiddling diff old.cfg new.cfg
          twiddling diff base.tw7 mine.tw7 --no-color
      TEXT

      def initialize(argv:, stdout: $stdout, stderr: $stderr)
        @argv = argv
        @stdout = stdout
        @stderr = stderr
        @color = true
        parse_flags!
      end

      def run
        return @stdout.puts(HELP_TEXT) if help?
        validate!
        print_diff
      end

      private

      def path_a = @positional[0]

      def path_b = @positional[1]

      def help? = @argv.include?("-h") || @argv.include?("--help")

      def parse_flags!
        @positional = []
        @argv.each do |arg|
          if arg == "--no-color"
            @color = false
          elsif !arg.start_with?("-")
            @positional << arg
          end
        end
      end

      def validate!
        raise ExitException, HELP_TEXT unless path_a && path_b
        [path_a, path_b].each do |path|
          raise ExitException, "File not found: #{path}" unless File.exist?(path)
          next if READABLE_EXTS.include?(File.extname(path))
          raise ExitException, "Unsupported file type: #{path}"
        end
      end

      def config_a = @config_a ||= load_config(path_a)

      def config_b = @config_b ||= load_config(path_b)

      def load_config(path)
        case File.extname(path)
        when ".cfg" then V7::Config.from_file(path)
        when ".tw7" then V7::Tw7::Parser.new(File.read(path)).parse
        end
      end

      def print_diff
        printed = false
        printed |= print_settings_diff
        printed |= print_chord_diff
        @stdout.puts "No differences." unless printed
      end

      def print_settings_diff
        changes = settings_changes
        return false if changes.empty?

        @stdout.puts "Settings:"
        changes.each do |key, old_val, new_val|
          @stdout.puts color("  #{key}: #{old_val} -> #{new_val}", :yellow)
        end
        @stdout.puts
        true
      end

      def settings_changes
        old_s = effective_settings(config_a)
        new_s = effective_settings(config_b)
        old_s.filter_map do |key, old_val|
          new_val = new_s[key]
          [key, old_val, new_val] if old_val != new_val
        end
      end

      def effective_settings(config)
        V7::Tw7::SettingsFormatter.extract_settings(config)
      end

      def print_chord_diff
        old_chords = chord_map(config_a)
        new_chords = chord_map(config_b)
        buckets = classify_chord_changes(old_chords, new_chords)

        printed = false
        printed |= print_removed(buckets[:removed], old_chords)
        printed |= print_changed(buckets[:changed], old_chords, new_chords)
        printed |= print_added(buckets[:added], new_chords)
        printed
      end

      def classify_chord_changes(old_chords, new_chords)
        {
          removed: old_chords.keys - new_chords.keys,
          added: new_chords.keys - old_chords.keys,
          changed: (old_chords.keys & new_chords.keys).select { |bm| old_chords[bm] != new_chords[bm] }
        }
      end

      def chord_map(config)
        config.chords.to_h { |c| [c.bitmask, c] }
      end

      def print_removed(bitmasks, chords)
        return false if bitmasks.empty?

        @stdout.puts "Removed:"
        bitmasks.sort.each { |bm| @stdout.puts color("  #{format_chord(chords[bm])}", :red) }
        @stdout.puts
        true
      end

      def print_changed(bitmasks, old_chords, new_chords)
        return false if bitmasks.empty?

        @stdout.puts "Changed:"
        bitmasks.sort.each do |bm|
          buttons = format_buttons(old_chords[bm])
          old_effect = format_effect(old_chords[bm])
          new_effect = format_effect(new_chords[bm])
          @stdout.puts color("  #{buttons}: #{old_effect} -> #{new_effect}", :yellow)
        end
        @stdout.puts
        true
      end

      def print_added(bitmasks, chords)
        return false if bitmasks.empty?

        @stdout.puts "Added:"
        bitmasks.sort.each { |bm| @stdout.puts color("  #{format_chord(chords[bm])}", :green) }
        @stdout.puts
        true
      end

      def format_chord(chord)
        "#{format_buttons(chord)}: #{format_effect(chord)}"
      end

      def format_buttons(chord)
        prefix = chord.mouse_mode? ? "[MOUSEMODE] " : ""
        buttons = V7::Tw7::ButtonFormatter.format(
          chord.bitmask & ~V7::ChordConstants::MOUSE_MODE_FLAG
        )
        "#{prefix}#{buttons}"
      end

      def format_effect(chord)
        V7::Tw7::EffectFormatter.format_effect(chord)
      end

      COLORS = {red: 31, green: 32, yellow: 33}.freeze

      def color(text, name)
        return text unless @color

        "\e[#{COLORS[name]}m#{text}\e[0m"
      end
    end
  end
end
