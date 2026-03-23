module Twiddling
  module V7
    class Chord
      include ChordConstants

      attr_reader :bitmask, :modifier_type, :keycode, :string_keys

      def initialize(bitmask:, modifier_type:, keycode:, string_keys: nil)
        @bitmask = bitmask
        @modifier_type = modifier_type
        @keycode = keycode
        @string_keys = string_keys
      end

      def type_byte = modifier_type & 0xFF

      def type_name
        case type_byte
        when TYPE_DEVICE then :device
        when TYPE_KEYBOARD then :keyboard
        when TYPE_MULTICHAR then :multichar
        end
      end

      def modifier_byte = (modifier_type >> 8) & 0xFF

      def mouse_mode? = bitmask & MOUSE_MODE_FLAG != 0

      def key_name = HID_KEYS[keycode]

      def modifier_names
        MODIFIERS.filter_map { |bit, name| name if modifier_byte & bit != 0 }
      end

      def device_function
        DEVICE_FUNCTIONS[modifier_byte] if type_byte == TYPE_DEVICE
      end

      def ==(other)
        other.is_a?(self.class) &&
          bitmask == other.bitmask &&
          modifier_type == other.modifier_type &&
          keycode == other.keycode &&
          string_keys == other.string_keys
      end
    end
  end
end
