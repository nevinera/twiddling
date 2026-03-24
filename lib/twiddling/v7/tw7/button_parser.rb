module Twiddling
  module V7
    module Tw7
      # Parses T4 button notation into a bitmask.
      #
      # Accepts various forms:
      #   "T14 F1L F2M"   - full notation
      #   "T14 1L 2M"     - F prefix optional for fingers
      #   "T14 1L2M"      - spaces optional between finger tokens
      #   "t14 f1l f2m"   - case-insensitive
      #   "1LR"           - multiple columns in one token
      #
      # A space or F is required between thumb buttons and finger
      # buttons (T141R is ambiguous, use T14 1R).
      module ButtonParser
        include ConfigConstants

        BUTTON_NAME_TO_BIT = BUTTON_BITS.to_h { |bit, name|
          [name.to_s, bit]
        }.freeze

        module_function

        def parse(text)
          thumb_part, finger_part = split_thumb_finger(text.strip.upcase)
          mask = 0
          mask |= parse_thumbs(thumb_part) if thumb_part
          mask |= parse_fingers(finger_part) if finger_part
          raise ArgumentError, "Invalid button spec: #{text}" if mask == 0
          mask
        end

        private

        # Split on the boundary between thumb (T...) and finger parts.
        # Returns [thumb_string_or_nil, finger_string_or_nil].
        def split_thumb_finger(text)
          if text.start_with?("T")
            match = text.match(/\A(T\d+)\s*(.*)?\z/)
            raise ArgumentError, "Invalid button spec: #{text}" unless match
            thumb = match[1]
            rest = match[2]&.strip
            [thumb, rest&.empty? ? nil : rest]
          else
            [nil, text]
          end
        end

        # "T14" -> T1 + T4
        def parse_thumbs(text)
          text[1..].chars.reduce(0) do |mask, digit|
            bit = BUTTON_NAME_TO_BIT["T#{digit}"]
            raise ArgumentError, "Unknown thumb button: T#{digit}" unless bit
            mask | (1 << bit)
          end
        end

        # "F1L2M" or "1L2M" or "F1LR" -> walk chars
        def parse_fingers(text)
          tokens = text.delete(" \t").gsub(/F(?=\d)/, "").scan(/\d[LMR]+/)
          tokens.reduce(0) { |mask, token| mask | resolve_finger_token(token) }
        end

        def resolve_finger_token(token)
          row = token[0]
          token[1..].chars.reduce(0) do |mask, col|
            bit = BUTTON_NAME_TO_BIT["F#{row}#{col}"]
            raise ArgumentError, "Unknown button: F#{row}#{col}" unless bit
            mask | (1 << bit)
          end
        end

        module_function :split_thumb_finger, :parse_thumbs, :parse_fingers,
          :resolve_finger_token
      end
    end
  end
end
