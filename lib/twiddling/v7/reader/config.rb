module Twiddling
  module V7
    module Reader
      # Parses a complete v7 binary config file into a V7::Config.
      #
      # Binary layout:
      #   0x00-0x7F: 128-byte header (flags, settings, index table)
      #   0x80+:     8-byte chord entries (chord_count of them)
      #   after chords: string table (variable length, may be empty)
      class Config
        include ConfigConstants

        def initialize(data)
          @data = data
        end

        def parse
          header = parse_header
          string_table = parse_string_table(header[:chord_count])
          chords = parse_chords(header[:chord_count], string_table)
          V7::Config.new(header.merge(chords: chords))
        end

        private

        def parse_header
          parse_header_fields.merge(parse_header_regions)
        end

        def parse_header_fields
          version, format_version, flags_1, flags_2, flags_3,
            chord_count, idle_time, key_repeat, reserved_0e =
            @data[0, 16].unpack("VCCCCvvvv")

          {version:, format_version:, flags_1:, flags_2:, flags_3:,
           chord_count:, idle_time:, key_repeat:, reserved_0e:}
        end

        def parse_header_regions
          {
            reserved_10: @data[0x10, 48],
            thumb_modifiers: @data[0x40, 16].unpack("V4"),
            dedicated_buttons: @data[0x50, 4].unpack("C4"),
            reserved_54: @data[0x54, 12],
            index_table: @data[0x60, 32].unpack("C32")
          }
        end

        def parse_string_table(chord_count)
          offset = HEADER_SIZE + (chord_count * ChordConstants::ENTRY_SIZE)
          table_data = @data[offset..]
          return nil unless table_data && !table_data.empty?

          Reader::StringTable.new(table_data).parse
        end

        def parse_chords(chord_count, string_table)
          chord_count.times.map do |i|
            offset = HEADER_SIZE + (i * ChordConstants::ENTRY_SIZE)
            Reader::Chord.new(@data[offset, ChordConstants::ENTRY_SIZE], string_table: string_table).parse
          end
        end
      end
    end
  end
end
