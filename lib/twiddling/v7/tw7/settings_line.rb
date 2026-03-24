module Twiddling
  module V7
    module Tw7
      # A single line from the settings section of a .tw7 file.
      class SettingsLine
        attr_reader :line_number, :line_text

        def initialize(line_number:, line_text:)
          @line_number = line_number
          @line_text = line_text
        end

        def key
          line_text.split(":", 2).first.strip
        end

        def value
          line_text.split(":", 2).last.strip
        end
      end
    end
  end
end
