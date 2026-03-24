module Twiddling
  module V7
    module Tw7
      # Prints a V7::Config as .tw7 text format.
      class Printer
        def initialize(config, io: $stdout)
          @config = config
          @io = io
        end

        def print
          settings_lines = SettingsFormatter.format(@config)
          print_settings(settings_lines) if settings_lines.any?
          print_chords
        end

        private

        def print_settings(lines)
          lines.each { |line| @io.puts line }
          @io.puts "====="
        end

        def print_chords
          groups = group_chords
          groups.each_with_index do |(thumb_key, chords), idx|
            @io.puts if idx > 0
            print_group(thumb_key, chords)
          end
        end

        def group_chords
          grouped = {}
          @config.chords.each do |chord|
            key = ButtonFormatter.thumb_key(chord.bitmask) || ""
            (grouped[key] ||= []) << chord
          end
          sort_groups(grouped)
        end

        # Sort: no-thumb first, then by thumb combo length, then alphabetically
        def sort_groups(grouped)
          grouped.sort_by { |key, _| [key.empty? ? 0 : 1, key.length, key] }
        end

        def print_group(thumb_key, chords)
          if thumb_key.empty?
            chords.each { |chord| print_chord(chord, "") }
          elsif chords.length == 1
            print_chord(chords[0], "")
          else
            @io.puts "#{thumb_key}::"
            chords.each { |chord| print_chord(chord, "  ") }
          end
        end

        def print_chord(chord, indent)
          buttons = if indent.empty?
            ButtonFormatter.format(chord.bitmask)
          else
            ButtonFormatter.finger_part(chord.bitmask)
          end
          effect = EffectFormatter.format(chord)
          @io.puts "#{indent}#{buttons}: #{effect}"
        end
      end
    end
  end
end
