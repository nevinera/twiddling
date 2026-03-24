module Twiddling
  module V7
    module Tw7
      # Parses a .tw7 text file into a V7::Config.
      class Parser
        DIVIDER = /\A={5,}\z/
        MOUSEMODE_SCOPE = "[MOUSEMODE]"

        def initialize(text, base: nil)
          @text = text
          @base = base || default_base
        end

        def parse
          settings_lines, chord_lines = split_sections
          attrs = build_attrs(settings_lines)
          chords = parse_chords(chord_lines)
          sorted = chords.sort_by(&:bitmask)
          attrs[:chords] = sorted
          attrs[:index_table] = Config.compute_index_table(sorted)
          Config.new(attrs)
        end

        private

        def default_base
          Config.from_file(
            File.expand_path("../data/default_base.cfg", __dir__)
          )
        end

        def split_sections
          lines = strip_comments(@text.lines.map(&:rstrip))
          divider_idx = lines.index { |l| l.match?(DIVIDER) }
          if divider_idx
            [lines[0...divider_idx], lines[(divider_idx + 1)..]]
          else
            [[], lines]
          end
        end

        def strip_comments(lines)
          lines.map { |line| strip_line_comment(line) }
        end

        # Remove # comments. A # starts a comment unless it's
        # inside double quotes.
        def strip_line_comment(line)
          in_quotes = false
          line.each_char.with_index do |ch, i|
            if ch == '"'
              in_quotes = !in_quotes
            elsif ch == "#" && !in_quotes
              return line[0, i].rstrip
            end
          end
          line
        end

        def build_attrs(settings_lines)
          non_blank = settings_lines.reject(&:empty?)
          parsed = SettingsParser.parse(non_blank)
          settings = Settings.new(
            thumb_modifiers: parsed.delete(:thumb_modifiers),
            dedicated_buttons: parsed.delete(:dedicated_buttons),
            reserved: @base.settings.reserved
          )
          base_attrs.merge(parsed).merge(settings: settings)
        end

        def base_attrs
          Config::ATTR_NAMES.to_h { |name| [name, @base.public_send(name)] }
        end

        def parse_chords(lines)
          chords = []
          scope_bitmask = 0
          mousemode = false

          lines.each_with_index do |line, idx|
            next if line.strip.empty?
            parse_chord_line(line, idx, chords, scope_bitmask, mousemode)
              .then { |new_scope, new_mouse| scope_bitmask, mousemode = new_scope, new_mouse }
          end

          chords
        end

        def parse_chord_line(line, idx, chords, scope_bitmask, mousemode)
          indented = line.start_with?("  ", "\t")
          content = line.strip

          if content.end_with?("::")
            open_scope(content, mousemode)
          elsif indented
            chords << build_chord(content, scope_bitmask, mousemode, idx)
            [scope_bitmask, mousemode]
          else
            chords << build_chord(content, 0, false, idx)
            [0, false]
          end
        end

        def open_scope(content, _mousemode)
          scope_text = content.chomp("::")
          if scope_text == MOUSEMODE_SCOPE
            [0, true]
          else
            [ButtonParser.parse(scope_text), false]
          end
        end

        def build_chord(content, scope_bitmask, mousemode, line_idx)
          buttons_text, effect_text = content.split(":", 2)
          raise ArgumentError, "Line #{line_idx + 1}: missing effect" unless effect_text

          bitmask = ButtonParser.parse(buttons_text) | scope_bitmask
          bitmask |= ChordConstants::MOUSE_MODE_FLAG if mousemode
          effect = EffectParser.parse(effect_text)

          Chord.new(
            bitmask: bitmask,
            modifier_type: effect[:modifier_type],
            keycode: effect[:keycode],
            string_keys: effect[:string_keys]
          )
        rescue ArgumentError => e
          raise ArgumentError, "Line #{line_idx + 1}: #{e.message}"
        end
      end
    end
  end
end
