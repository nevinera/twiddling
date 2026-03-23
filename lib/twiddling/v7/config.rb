module Twiddling
  module V7
    class Config
      HEADER_SIZE = 128
      CHORD_ENTRY_SIZE = 8

      # Button bitmask bit positions
      BUTTON_BITS = {
        0 => :T1, 1 => :F1L, 2 => :F1M, 3 => :F1R,
        4 => :T2, 5 => :F2L, 6 => :F2M, 7 => :F2R,
        8 => :T3, 9 => :F3L, 10 => :F3M, 11 => :F3R,
        12 => :T4, 13 => :F4L, 14 => :F4M, 15 => :F4R,
        16 => :F0L, 17 => :F0M, 18 => :F0R
      }.freeze

      # Thumb modifier assignment codes
      THUMB_MODIFIERS = {
        0 => :num, 1 => :l_control, 2 => :l_shift,
        3 => :l_option, 4 => :l_command
      }.freeze

      # Dedicated button function codes
      DEDICATED_FUNCTIONS = {
        0x00 => :none, 0x09 => :mouse_left,
        0x0a => :mouse_right, 0x0b => :mouse_middle
      }.freeze

      ATTR_NAMES = %i[
        version format_version flags_1 flags_2 flags_3
        idle_time key_repeat reserved_0e reserved_10
        thumb_modifiers dedicated_buttons reserved_54
        index_table chords
      ].freeze

      attr_reader(*ATTR_NAMES)

      def initialize(attrs)
        ATTR_NAMES.each { |name| instance_variable_set(:"@#{name}", attrs[name]) }
      end

      def self.from_file(path) = from_binary(File.binread(path))

      def self.from_binary(data)
        header = parse_header(data)
        string_table = build_string_table(data, header[:chord_count])
        chords = parse_chords(data, header[:chord_count], string_table)
        new(header.merge(chords: chords))
      end

      def to_binary = binary_header + binary_chords + binary_string_table

      def write(path) = File.binwrite(path, to_binary)

      def chord_count = chords.length

      private

      def binary_header
        header_fields_packed + reserved_10 + settings_packed + index_table.pack("C32")
      end

      def header_fields_packed
        [
          version, format_version, flags_1, flags_2, flags_3,
          chord_count, idle_time, key_repeat, reserved_0e
        ].pack("VCCCCvvvv")
      end

      def settings_packed
        thumb_modifiers.pack("V4") + dedicated_buttons.pack("C4") + reserved_54
      end

      def binary_chords
        offsets = compute_string_offsets
        chords.each_with_index.map { |chord, i|
          chord.to_binary(string_table_offset: offsets[i])
        }.join
      end

      def binary_string_table
        Writer::StringTable.new(build_output_string_table).to_binary
      end

      def build_output_string_table
        entries = []
        offset = 0
        chords.each do |chord|
          next unless chord.string_keys
          entries << StringTableEntry.new(keys: chord.string_keys, byte_offset: offset)
          offset += (chord.string_keys.length + 1) * 4
        end
        StringTable.new(entries)
      end

      def compute_string_offsets
        table = build_output_string_table
        chords.map { |chord|
          next unless chord.string_keys
          table.entries.find { |e| e.keys == chord.string_keys }&.byte_offset
        }
      end

      class << self
        private

        def parse_header(data)
          fields = parse_header_fields(data)
          fields.merge(parse_header_regions(data))
        end

        def parse_header_fields(data)
          version, format_version, flags_1, flags_2, flags_3,
            chord_count, idle_time, key_repeat, reserved_0e =
            data[0, 16].unpack("VCCCCvvvv")

          {version:, format_version:, flags_1:, flags_2:, flags_3:,
           chord_count:, idle_time:, key_repeat:, reserved_0e:}
        end

        def parse_header_regions(data)
          {
            reserved_10: data[0x10, 48],
            thumb_modifiers: data[0x40, 16].unpack("V4"),
            dedicated_buttons: data[0x50, 4].unpack("C4"),
            reserved_54: data[0x54, 12],
            index_table: data[0x60, 32].unpack("C32")
          }
        end

        def build_string_table(data, chord_count)
          table_offset = HEADER_SIZE + (chord_count * CHORD_ENTRY_SIZE)
          table_data = data[table_offset..]
          return nil unless table_data && !table_data.empty?

          Reader::StringTable.new(table_data).parse
        end

        def parse_chords(data, chord_count, string_table)
          chord_count.times.map { |i|
            offset = HEADER_SIZE + (i * CHORD_ENTRY_SIZE)
            Chord.from_binary(data[offset, CHORD_ENTRY_SIZE], string_table: string_table)
          }
        end
      end
    end
  end
end
