module Twiddling
  module V7
    # Device settings from the config header (offsets 0x40-0x5F).
    #
    # Contains thumb button modifier assignments, dedicated button
    # functions, and a reserved region.
    class Settings
      include ConfigConstants

      BINARY_SIZE = 32

      attr_reader :thumb_modifiers, :dedicated_buttons, :reserved

      def initialize(thumb_modifiers:, dedicated_buttons:, reserved:)
        @thumb_modifiers = thumb_modifiers
        @dedicated_buttons = dedicated_buttons
        @reserved = reserved
      end
    end
  end
end
