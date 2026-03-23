module Twiddling
  module V7
    module Writer
      # Serializes a V7::Chord back to 8 bytes of binary data.
      #
      # For multi-char chords, a string_table_offset must be provided
      # to encode the correct byte offset into the modifier_type field.
      # For other chord types, modifier_type is written as-is.
      class Chord
        include ChordConstants

        def initialize(chord, string_table_offset: nil)
          @chord = chord
          @string_table_offset = string_table_offset
        end

        def to_binary
          [@chord.bitmask, effective_modifier_type, @chord.keycode].pack("Vvv")
        end

        private

        # For multi-char chords being written with a new offset,
        # rebuild modifier_type from the type byte + offset.
        # Otherwise, preserve the original modifier_type.
        def effective_modifier_type
          if @string_table_offset
            TYPE_MULTICHAR | (@string_table_offset << 8)
          else
            @chord.modifier_type
          end
        end
      end
    end
  end
end
