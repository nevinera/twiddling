module Twiddling
  module V7
    module Reader
      # Parses an 8-byte chord entry from v7 binary config data.
      #
      # Binary layout (all little-endian):
      #
      #   Bytes 0-3: bitmask (u32) - button combination + flags
      #   Bytes 4-5: modifier_type (u16) - type in low byte, modifier/function/offset in high byte
      #   Bytes 6-7: keycode (u16) - HID keycode for keyboard chords, 0 otherwise
      #
      # For multi-char chords (type 0x07), the high byte of modifier_type
      # is a byte offset into the string table. The string_table argument
      # is used to resolve that offset into a key sequence.
      class Chord
        include ChordConstants

        def initialize(data, string_table: nil)
          @data = data
          @string_table = string_table
        end

        def parse
          bitmask, modifier_type, keycode = @data.unpack("Vvv")
          string_keys = resolve_string_keys(modifier_type)

          V7::Chord.new(
            bitmask: bitmask,
            modifier_type: modifier_type,
            keycode: keycode,
            string_keys: string_keys
          )
        end

        private

        # Looks up the string table entry for a multi-char chord.
        # Returns nil for non-multichar chords or when no table is present.
        def resolve_string_keys(modifier_type)
          return nil unless @string_table
          return nil unless (modifier_type & 0xFF) == TYPE_MULTICHAR

          offset = (modifier_type >> 8) & 0xFF
          @string_table.entry_at_offset(offset)&.keys
        end
      end
    end
  end
end
