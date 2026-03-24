module Twiddling
  module V7
    module Tw7
      # Formats a chord's effect (output) as tw7 text.
      module EffectFormatter
        include ChordConstants

        module_function

        def format_effect(chord)
          case chord.type_name
          when :keyboard then format_keyboard(chord)
          when :device then format_device(chord)
          when :multichar then format_multichar(chord)
          else "0x%04x" % chord.modifier_type
          end
        end

        def format_keyboard(chord)
          mods = chord.modifier_names.map(&:downcase)
          key = chord.key_name || ("0x%04x" % chord.keycode)

          result = if mods == ["shift"] && SHIFTED_KEYS[key]
            SHIFTED_KEYS[key]
          elsif mods.empty?
            key
          else
            (mods + [key]).join("+")
          end

          format_ambiguous(result, chord)
        end

        # Characters that can't appear as bare effects.
        # # starts a comment, " starts a string literal.
        QUOTE_CHARS = Set.new(["#"]).freeze
        UNQUOTABLE_CHARS = Set.new(['"']).freeze

        def format_ambiguous(result, chord)
          if UNQUOTABLE_CHARS.include?(result)
            # Can't quote " inside double quotes - use explicit modifier form
            mods = chord.modifier_names.map(&:downcase)
            key = chord.key_name
            (mods + [key]).join("+")
          elsif QUOTE_CHARS.include?(result)
            %("#{result}")
          else
            result
          end
        end

        def format_device(chord)
          chord.device_function&.to_s || ("device_0x%02x" % chord.modifier_byte)
        end

        def format_multichar(chord)
          return "multichar_0x%04x" % chord.modifier_type unless chord.string_keys

          chars = chord.string_keys.map { |sk| string_key_to_char(sk) }.join
          %("#{chars}")
        end

        def string_key_to_char(sk)
          key = HID_KEYS[sk[:hid_code]]
          return "?" unless key
          return KEY_TO_CHAR[key] if KEY_TO_CHAR.key?(key)

          shifted = ((sk[:modifier] >> 8) & MODIFIER_SHIFT) != 0
          if shifted && key.length == 1
            SHIFTED_KEYS[key] || key.upcase
          else
            key
          end
        end
      end
    end
  end
end
