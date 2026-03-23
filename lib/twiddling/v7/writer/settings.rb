module Twiddling
  module V7
    module Writer
      # Serializes a V7::Settings back to 32 bytes of binary data
      # for the config header (offsets 0x40-0x5F).
      class Settings
        def initialize(settings)
          @settings = settings
        end

        def to_binary
          @settings.thumb_modifiers.pack("V4") +
            @settings.dedicated_buttons.pack("C4") +
            @settings.reserved
        end
      end
    end
  end
end
