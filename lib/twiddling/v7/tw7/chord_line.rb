module Twiddling
  module V7
    module Tw7
      # A single chord line from the chords section of a .tw7 file.
      # line_text is the stripped content, e.g. "1R: c" or "T4 1M: space".
      class ChordLine
        attr_reader :line_number, :line_text

        def initialize(line_number:, line_text:)
          @line_number = line_number
          @line_text = line_text
        end

        # Returns the parsed button bitmask for this chord's own buttons.
        def buttons
          ButtonParser.parse(buttons_text)
        rescue ArgumentError => e
          raise ArgumentError, "Line #{line_number}: #{e.message}"
        end

        # Returns the parsed effect hash: {modifier_type:, keycode:, string_keys:}.
        def value
          EffectParser.parse(value_text)
        rescue ArgumentError => e
          raise ArgumentError, "Line #{line_number}: #{e.message}"
        end

        private

        def buttons_text
          parts = line_text.split(":", 2)
          raise ArgumentError, "Line #{line_number}: missing effect" unless parts.length == 2
          parts.first
        end

        def value_text
          parts = line_text.split(":", 2)
          raise ArgumentError, "Line #{line_number}: missing effect" unless parts.length == 2
          parts.last
        end
      end
    end
  end
end
