module Twiddling
  module V7
    module Writer
      # Serializes a V7::Config back to the v7 binary format.
      #
      # Produces three sections concatenated:
      #   1. 128-byte header
      #   2. 8-byte chord entries
      #   3. String table (for multi-char chords)
      #
      # String table offsets in multi-char chord entries are
      # recomputed during serialization to match the output layout.
      class Config
        include ConfigConstants

        def initialize(config)
          @config = config
        end

        def to_binary
          header_binary + chords_binary + string_table_binary
        end

        private

        def header_binary
          header_fields + @config.reserved_10 + settings_fields + index_table_field
        end

        def header_fields
          [
            @config.version, @config.format_version,
            @config.flags_1, @config.flags_2, @config.flags_3,
            @config.chord_count, @config.idle_time,
            @config.key_repeat, @config.reserved_0e
          ].pack("VCCCCvvvv")
        end

        def settings_fields
          @config.thumb_modifiers.pack("V4") +
            @config.dedicated_buttons.pack("C4") +
            @config.reserved_54
        end

        def index_table_field
          @config.index_table.pack("C32")
        end

        def chords_binary
          offsets = compute_string_offsets
          @config.chords.each_with_index.map { |chord, i|
            Writer::Chord.new(chord, string_table_offset: offsets[i]).to_binary
          }.join
        end

        def string_table_binary
          Writer::StringTable.new(build_string_table).to_binary
        end

        def build_string_table
          entries = []
          offset = 0
          @config.chords.each do |chord|
            next unless chord.string_keys
            entries << StringTableEntry.new(keys: chord.string_keys, byte_offset: offset)
            offset += (chord.string_keys.length + 1) * 4
          end
          V7::StringTable.new(entries)
        end

        def compute_string_offsets
          table = build_string_table
          @config.chords.map do |chord|
            next unless chord.string_keys
            table.entries.find { |e| e.keys == chord.string_keys }&.byte_offset
          end
        end
      end
    end
  end
end
