module Twiddling
  module V7
    module Tw7
      # Formats a chord bitmask as T4 notation button strings.
      #
      # Produces compact notation: thumb buttons combined (T14),
      # finger buttons grouped by row (F1LR, F2M).
      module ButtonFormatter
        include ConfigConstants

        module_function

        # Returns the full button string for a bitmask (e.g. "T14 F1L F2M").
        def format(bitmask)
          thumbs, fingers = partition_buttons(bitmask)
          parts = []
          parts << format_thumbs(thumbs) unless thumbs.empty?
          fingers.sort.each { |row, cols| parts << "F#{row}#{cols.join}" }
          parts.join(" ")
        end

        # Returns just the thumb portion of a bitmask (e.g. "T14").
        # Returns nil if no thumb buttons.
        def thumb_key(bitmask)
          thumbs, _ = partition_buttons(bitmask)
          return nil if thumbs.empty?
          format_thumbs(thumbs)
        end

        # Returns the finger portion of a bitmask (e.g. "F1L F2M"),
        # excluding thumb buttons.
        def finger_part(bitmask)
          _, fingers = partition_buttons(bitmask)
          fingers.sort.map { |row, cols| "F#{row}#{cols.join}" }.join(" ")
        end

        def partition_buttons(bitmask)
          thumbs = []
          fingers = {}

          BUTTON_BITS.each do |bit, name|
            next unless bitmask[bit] == 1
            classify_button(name, thumbs, fingers)
          end

          [thumbs, fingers]
        end

        def classify_button(name, thumbs, fingers)
          if name.start_with?("T")
            thumbs << name[1..].to_i
          else
            (fingers[name[1].to_i] ||= []) << name[2..].to_sym
          end
        end

        def format_thumbs(thumbs)
          "T#{thumbs.sort.join}"
        end
      end
    end
  end
end
