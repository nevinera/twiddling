module Twiddling
  module V7
    module Tw7
      # Parses a .tw7 text file into a V7::Config.
      class Parser
        def initialize(text, base: nil)
          @text = text
          @base = base || default_base
        end

        def parse
          config_data = Structurer.new(@text).structure
          attrs = build_attrs(config_data.settings_lines)
          chords = parse_chords(config_data.chord_lines)
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

        def build_attrs(settings_lines)
          parsed = SettingsParser.parse(settings_lines.map(&:line_text))
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

        def parse_chords(items, scope_bitmask: 0, mousemode: false)
          items.flat_map do |item|
            case item
            when ChordScopeLine
              if item.mousemode?
                parse_chords(item.children, scope_bitmask: 0, mousemode: true)
              else
                parse_chords(item.children, scope_bitmask: scope_bitmask | item.buttons, mousemode: mousemode)
              end
            when ChordLine
              [build_chord(item, scope_bitmask, mousemode)]
            end
          end
        end

        def build_chord(chord_line, scope_bitmask, mousemode)
          effect = chord_line.value
          bitmask = chord_line.buttons | scope_bitmask
          bitmask |= ChordConstants::MOUSE_MODE_FLAG if mousemode
          Chord.new(
            bitmask: bitmask,
            modifier_type: effect[:modifier_type],
            keycode: effect[:keycode],
            string_keys: effect[:string_keys]
          )
        end
      end
    end
  end
end
