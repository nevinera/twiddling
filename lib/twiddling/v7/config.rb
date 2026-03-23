module Twiddling
  module V7
    class Config
      include ConfigConstants

      ATTR_NAMES = %i[
        version format_version flags_1 flags_2 flags_3
        idle_time key_repeat reserved_0e reserved_10
        settings index_table chords
      ].freeze

      attr_reader(*ATTR_NAMES)

      def initialize(attrs)
        ATTR_NAMES.each { |name| instance_variable_set(:"@#{name}", attrs[name]) }
      end

      def self.from_file(path)
        config = Reader::Config.new(File.binread(path)).parse
        config.validate!
        config
      end

      def self.from_binary(data)
        config = Reader::Config.new(data).parse
        config.validate!
        config
      end

      def to_binary = Writer::Config.new(self).to_binary

      def write(path) = File.binwrite(path, to_binary)

      def chord_count = chords.length

      # Returns a new Config with the chord added, sorted by bitmask,
      # with the index table recomputed.
      def add_chord(chord)
        new_chords = (chords + [chord]).sort_by(&:bitmask)
        with(chords: new_chords, index_table: self.class.compute_index_table(new_chords))
      end

      # Returns a new Config with all chords matching the given bitmask
      # (low 16 bits) removed, with the index table recomputed.
      def remove_chord(bitmask)
        target = bitmask & 0xFFFF
        new_chords = chords.reject { |c| (c.bitmask & 0xFFFF) == target }
        with(chords: new_chords, index_table: self.class.compute_index_table(new_chords))
      end

      # Computes the 32-byte index table for a sorted list of chords.
      # Each entry maps the low 5 bits of a bitmask prefix to the
      # index of the first chord with that prefix. 0x80 = no match.
      def self.compute_index_table(chords)
        table = Array.new(32, 0x80)
        chords.each_with_index do |chord, idx|
          prefix = chord.bitmask & 0x1F
          table[prefix] = idx if table[prefix] == 0x80
        end
        table
      end

      # Returns a new Config with the given attributes replaced.
      def set(**overrides)
        with(**overrides)
      end

      # Returns a new Config with the given Settings.
      def with_settings(new_settings)
        with(settings: new_settings)
      end

      def validator = @validator ||= Validator.new(self)

      def validate = validator.validate

      def validate! = validator.validate!

      # Convenience delegators to settings
      def thumb_modifiers = settings.thumb_modifiers

      def dedicated_buttons = settings.dedicated_buttons

      private

      def attrs
        ATTR_NAMES.to_h { |name| [name, public_send(name)] }
      end

      def with(**overrides)
        config = self.class.new(attrs.merge(overrides))
        config.validate!
        config
      end

      # Builds a new Config without validation - only for testing.
      def with_no_validate(**overrides)
        self.class.new(attrs.merge(overrides))
      end
    end
  end
end
