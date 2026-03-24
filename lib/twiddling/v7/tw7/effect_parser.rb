module Twiddling
  module V7
    module Tw7
      # Parses a chord effect string into modifier_type, keycode,
      # and optional string_keys.
      #
      # Accepts:
      #   "c"           - plain key
      #   "@"           - shifted symbol
      #   "ctrl+c"      - modifier+key
      #   "cmd+shift+a" - multiple modifiers
      #   '"the "'      - multi-char string (double-quoted)
      #   "speed_cycle" - device function name
      module EffectParser
        include ChordConstants

        # Reverse lookups
        KEY_TO_HID = HID_KEYS.to_h { |hid, name| [name, hid] }.freeze
        SHIFTED_TO_BASE = SHIFTED_KEYS.to_h { |base, shifted| [shifted, base] }.freeze
        FUNCTION_TO_CODE = DEVICE_FUNCTIONS.to_h { |code, name| [name.to_s, code] }.freeze
        MODIFIER_NAME_TO_BIT = MODIFIERS.to_h { |bit, name| [name.downcase, bit] }.freeze
        CHAR_TO_KEY = KEY_TO_CHAR.to_h { |name, char| [char, name] }.freeze

        module_function

        # Returns {modifier_type:, keycode:, string_keys:}
        def parse(text)
          text = text.strip
          return parse_quoted(text) if text.start_with?('"') && text.end_with?('"')

          classify_and_parse(text)
        end

        def parse_quoted(text)
          inner = text[1..-2]
          (inner.length == 1) ? parse_quoted_char(inner) : parse_string(inner)
        end

        def classify_and_parse(text)
          if FUNCTION_TO_CODE.key?(text) then parse_device_function(text)
          elsif SHIFTED_TO_BASE.key?(text) then parse_key(text)
          elsif text.include?("+") then parse_modified_key(text)
          elsif text.match?(/\A0x[0-9a-f]+\z/i) then parse_hex_key(text)
          else
            parse_key(text)
          end
        end

        private

        def parse_key(text)
          if (base = SHIFTED_TO_BASE[text])
            hid = KEY_TO_HID[base] || raise(ArgumentError, "Unknown key: #{text}")
            {modifier_type: TYPE_KEYBOARD | (MODIFIER_SHIFT << 8), keycode: hid}
          else
            hid = KEY_TO_HID[text] || raise(ArgumentError, "Unknown key: #{text}")
            {modifier_type: TYPE_KEYBOARD, keycode: hid}
          end
        end

        def parse_modified_key(text)
          parts = text.split("+")
          key_name = parts.pop
          mod_byte = parts.reduce(0) { |m, name|
            bit = MODIFIER_NAME_TO_BIT[name.downcase]
            raise ArgumentError, "Unknown modifier: #{name}" unless bit
            m | bit
          }
          hid = KEY_TO_HID[key_name] || raise(ArgumentError, "Unknown key: #{key_name}")
          {modifier_type: TYPE_KEYBOARD | (mod_byte << 8), keycode: hid}
        end

        # A single-char quoted string like "#" is a keyboard chord,
        # not a multi-char string.
        def parse_quoted_char(char)
          sk = char_to_key(char)
          {modifier_type: sk[:modifier], keycode: sk[:hid_code]}
        end

        def parse_hex_key(text)
          {modifier_type: TYPE_KEYBOARD, keycode: Integer(text, 16)}
        end

        def parse_device_function(text)
          code = FUNCTION_TO_CODE[text]
          {modifier_type: TYPE_DEVICE | (code << 8), keycode: 0}
        end

        def parse_string(text)
          keys = text.chars.map { |ch| char_to_key(ch) }
          {modifier_type: TYPE_MULTICHAR, keycode: 0, string_keys: keys}
        end

        def char_to_key(char)
          hid, shifted = resolve_char(char)
          modifier = shifted ? (TYPE_KEYBOARD | (MODIFIER_SHIFT << 8)) : TYPE_KEYBOARD
          {modifier: modifier, hid_code: hid}
        end

        def resolve_char(char)
          hid, shifted = lookup_char(char)
          raise ArgumentError, "Unknown character: #{char}" unless hid
          [hid, shifted]
        end

        def lookup_char(char)
          if (base = SHIFTED_TO_BASE[char]) then [KEY_TO_HID[base], true]
          elsif char.match?(/[A-Z]/) then [KEY_TO_HID[char.downcase], true]
          else
            [KEY_TO_HID[CHAR_TO_KEY[char] || char], false]
          end
        end

        module_function :parse_quoted, :classify_and_parse, :parse_key,
          :parse_quoted_char, :parse_hex_key, :parse_modified_key,
          :parse_device_function, :parse_string, :char_to_key,
          :resolve_char, :lookup_char
      end
    end
  end
end
