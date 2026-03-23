module Twiddling
  module V7
    module Reader
      # Parses the string table region of a v7 binary config file.
      #
      # The string table is a sequence of null-terminated entries, each
      # consisting of (modifier u16 LE, hid_code u16 LE) pairs. It
      # appears at the end of the file, immediately after the chord
      # entries. Multi-char chords reference entries by byte offset.
      #
      # Binary layout of a single entry ("te"):
      #
      #   02 00 17 00   modifier=0x0002 hid_code=0x0017 (t)
      #   02 00 08 00   modifier=0x0002 hid_code=0x0008 (e)
      #   00 00 00 00   null terminator
      #
      # Multiple entries are concatenated. The byte offset of each entry
      # is stored in the chord's modifier_type high byte so the firmware
      # can jump directly to it.
      class StringTable
        # Each key pair is 4 bytes: modifier u16 + hid_code u16
        PAIR_SIZE = 4

        def initialize(data)
          @data = data.b
        end

        # Parses all entries sequentially, returning a V7::StringTable
        # with StringTableEntry objects that track their byte offsets.
        def parse
          entries = []
          offset = 0

          while offset < @data.length
            keys = read_keys(offset)
            break if keys.nil?

            entries << StringTableEntry.new(keys: keys, byte_offset: offset)
            # Advance past this entry's key pairs + the null terminator
            offset += (keys.length + 1) * PAIR_SIZE
          end

          V7::StringTable.new(entries)
        end

        private

        # Reads a single entry's keys starting at the given byte offset.
        # Returns nil if no valid pairs are found (end of table).
        def read_keys(offset)
          pairs = read_pairs(offset)
          keys = pairs.map { |mod, hid| {modifier: mod, hid_code: hid} }
          keys.empty? ? nil : keys
        end

        # Reads (modifier, hid_code) pairs until hitting a null terminator.
        def read_pairs(offset)
          each_pair(offset).take_while { |mod, hid| !null_terminator?(mod, hid) }
        end

        # Unpacks the raw bytes from the given offset as u16 LE values,
        # yielding [modifier, hid_code] pairs.
        def each_pair(offset) = @data[offset..].unpack("v*").each_slice(2)

        def null_terminator?(mod, hid) = mod == 0 && hid == 0
      end
    end
  end
end
