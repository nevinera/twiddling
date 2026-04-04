module Twiddling
  module V7
    module Tw7
      # A chord group header (ending with ::) from the chords section of a .tw7 file.
      # line_text is the stripped content, e.g. "T4::" or "1M::".
      # children holds the ChordLine and ChordScopeLine entries nested under this header.
      class ChordScopeLine
        MOUSEMODE_SCOPE = "[MOUSEMODE]"

        attr_reader :line_number, :line_text, :children

        def initialize(line_number:, line_text:)
          @line_number = line_number
          @line_text = line_text
          @children = []
        end

        # Returns the parsed button bitmask for this scope's own buttons.
        # Returns 0 for the [MOUSEMODE] scope.
        def buttons
          return 0 if mousemode?
          ButtonParser.parse(header_text)
        rescue ArgumentError => e
          raise ArgumentError, "Line #{line_number}: #{e.message}"
        end

        def mousemode?
          header_text == MOUSEMODE_SCOPE
        end

        private

        def header_text
          line_text.delete_suffix("::")
        end
      end
    end
  end
end
