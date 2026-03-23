module Twiddling
  module V7
    class Validator
      Error = Struct.new(:field, :message, keyword_init: true) do
        def to_s = "#{field}: #{message}"
      end

      ValidationError = Class.new(Twiddling::Error)

      def initialize(config)
        @config = config
      end

      def validate
        errors = []
        check_format_version(errors)
        check_chord_count(errors)
        check_sorted_bitmasks(errors)
        check_no_duplicate_bitmasks(errors)
        check_string_table_offsets(errors)
        errors
      end

      def validate!
        errors = validate
        return if errors.empty?

        messages = errors.map(&:to_s).join("; ")
        raise ValidationError, messages
      end

      private

      def check_format_version(errors)
        return if @config.format_version == 7

        errors << Error.new(
          field: :format_version,
          message: "expected 7, got #{@config.format_version}"
        )
      end

      def check_chord_count(errors)
        return if @config.chord_count <= 0xFFFF

        errors << Error.new(
          field: :chord_count,
          message: "exceeds u16 max (#{@config.chord_count})"
        )
      end

      def check_sorted_bitmasks(errors)
        bitmasks = @config.chords.map(&:bitmask)
        return if bitmasks == bitmasks.sort

        errors << Error.new(
          field: :chords,
          message: "chords are not sorted by bitmask"
        )
      end

      def check_no_duplicate_bitmasks(errors)
        seen = {}
        @config.chords.each_with_index do |chord, idx|
          if seen[chord.bitmask]
            errors << Error.new(
              field: :chords,
              message: "duplicate bitmask 0x%08x at indices %d and %d" %
                [chord.bitmask, seen[chord.bitmask], idx]
            )
          else
            seen[chord.bitmask] = idx
          end
        end
      end

      def check_string_table_offsets(errors)
        multichar_chords = @config.chords.select { |c| c.type_name == :multichar }
        return if multichar_chords.empty?

        multichar_chords.each do |chord|
          next if chord.string_keys && !chord.string_keys.empty?

          errors << Error.new(
            field: :chords,
            message: "multi-char chord (bitmask 0x%08x) has no string keys" %
              chord.bitmask
          )
        end
      end
    end
  end
end
