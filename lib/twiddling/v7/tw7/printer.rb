module Twiddling
  module V7
    module Tw7
      # Prints a V7::Config as .tw7 text format.
      class Printer
        MOUSEMODE_KEY = "[MOUSEMODE]"

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
          groups.each_with_index do |(group_key, chords), idx|
            @io.puts if idx > 0
            print_group(group_key, chords)
          end
        end

        def group_chords
          grouped = {}
          @config.chords.each do |chord|
            key = group_key(chord)
            (grouped[key] ||= []) << chord
          end
          sort_groups(grouped)
        end

        def group_key(chord)
          if chord.mouse_mode?
            MOUSEMODE_KEY
          else
            ButtonFormatter.thumb_key(chord.bitmask) || ""
          end
        end

        # Sort: no-thumb first, then by thumb combo length, then
        # alphabetically. MOUSEMODE sorts last.
        def sort_groups(grouped)
          grouped.sort_by { |key, _| sort_key(key) }
        end

        def sort_key(key)
          case key
          when "" then [0, 0, key]
          when MOUSEMODE_KEY then [3, 0, key]
          else [1, key.length, key]
          end
        end

        def print_group(group_key, chords)
          if group_key.empty?
            chords.each { |chord| print_standalone(chord) }
          elsif chords.length == 1
            print_standalone(chords[0])
          else
            @io.puts "#{group_key}::"
            chords.each { |chord| print_indented(chord, group_key) }
          end
        end

        def print_standalone(chord)
          buttons = format_all_buttons(chord)
          @io.puts "#{buttons}: #{EffectFormatter.format_effect(chord)}"
        end

        def print_indented(chord, group_key)
          buttons = format_nested_buttons(chord, group_key)
          @io.puts "  #{buttons}: #{EffectFormatter.format_effect(chord)}"
        end

        # Full button string for standalone chords, stripping mouse flag.
        def format_all_buttons(chord)
          ButtonFormatter.format(chord.bitmask & ~ChordConstants::MOUSE_MODE_FLAG)
        end

        # For indented chords, strip the group's contribution.
        # Thumb groups: show only fingers.
        # MOUSEMODE: show all buttons except the mouse flag.
        def format_nested_buttons(chord, group_key)
          clean = chord.bitmask & ~ChordConstants::MOUSE_MODE_FLAG
          if group_key == MOUSEMODE_KEY
            ButtonFormatter.format(clean)
          else
            ButtonFormatter.finger_part(clean)
          end
        end
      end
    end
  end
end
