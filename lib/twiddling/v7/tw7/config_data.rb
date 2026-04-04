module Twiddling
  module V7
    module Tw7
      # Intermediate representation of a parsed .tw7 file before semantic
      # interpretation. Holds raw line objects rather than Config values.
      class ConfigData
        attr_reader :settings_lines, :chord_lines

        def initialize(settings_lines:, chord_lines:)
          @settings_lines = settings_lines
          @chord_lines = chord_lines
        end
      end
    end
  end
end
