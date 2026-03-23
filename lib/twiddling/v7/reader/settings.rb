module Twiddling
  module V7
    module Reader
      # Parses the 32-byte settings region (offsets 0x40-0x5F) from
      # a v7 config header.
      #
      # Binary layout:
      #   0x40-0x4F: thumb modifier assignments (4 x u32 LE)
      #   0x50-0x53: dedicated button functions (4 x u8)
      #   0x54-0x5F: reserved (12 bytes, always zeros)
      class Settings
        def initialize(data)
          @data = data
        end

        def parse
          V7::Settings.new(
            thumb_modifiers: @data[0, 16].unpack("V4"),
            dedicated_buttons: @data[16, 4].unpack("C4"),
            reserved: @data[20, 12]
          )
        end
      end
    end
  end
end
