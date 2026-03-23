module Twiddling
  module V7
    module Writer
      # Serializes a V7::StringTable back to the binary format used
      # at the end of a v7 config file.
      #
      # Each entry becomes a sequence of (modifier u16 LE, hid_code
      # u16 LE) pairs followed by a null terminator (0x0000, 0x0000).
      # Entries are concatenated in order - their byte offsets in the
      # output match the offsets stored on each StringTableEntry.
      class StringTable
        def initialize(string_table)
          @string_table = string_table
        end

        # Returns the binary string table as a packed byte string.
        def to_binary
          @string_table.entries
            .flat_map { |entry| encode_entry(entry) }
            .pack("v*")
        end

        private

        # Encodes a single entry as a flat array of u16 values:
        # [mod1, hid1, mod2, hid2, ..., 0, 0]
        def encode_entry(entry)
          encode_keys(entry.keys) + null_terminator
        end

        # Flattens key hashes into [modifier, hid_code, ...] pairs.
        def encode_keys(keys)
          keys.flat_map { |sk| [sk[:modifier], sk[:hid_code]] }
        end

        def null_terminator = [0, 0]
      end
    end
  end
end
