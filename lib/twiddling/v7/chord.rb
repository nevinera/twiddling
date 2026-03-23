module Twiddling
  module V7
    class Chord
      ENTRY_SIZE = 8

      TYPE_DEVICE = 0x01
      TYPE_KEYBOARD = 0x02
      TYPE_MULTICHAR = 0x07

      MODIFIER_CTRL = 0x01
      MODIFIER_ALT = 0x04
      MODIFIER_CMD = 0x08
      MODIFIER_SHIFT = 0x20

      MODIFIERS = {
        MODIFIER_CTRL => "Ctrl",
        MODIFIER_ALT => "Alt",
        MODIFIER_CMD => "Cmd",
        MODIFIER_SHIFT => "Shift"
      }.freeze

      DEVICE_FUNCTIONS = {
        0x01 => :mouse_toggle,
        0x02 => :left_click,
        0x04 => :scroll_toggle,
        0x05 => :speed_decrease,
        0x06 => :speed_cycle,
        0x0a => :middle_click,
        0x0b => :speed_increase,
        0x0c => :right_click,
        0x0d => :print_stats,
        0x0e => :config_cycle
      }.freeze

      HID_KEYS = {
        0x04 => "a", 0x05 => "b", 0x06 => "c", 0x07 => "d",
        0x08 => "e", 0x09 => "f", 0x0a => "g", 0x0b => "h",
        0x0c => "i", 0x0d => "j", 0x0e => "k", 0x0f => "l",
        0x10 => "m", 0x11 => "n", 0x12 => "o", 0x13 => "p",
        0x14 => "q", 0x15 => "r", 0x16 => "s", 0x17 => "t",
        0x18 => "u", 0x19 => "v", 0x1a => "w", 0x1b => "x",
        0x1c => "y", 0x1d => "z",
        0x1e => "1", 0x1f => "2", 0x20 => "3", 0x21 => "4",
        0x22 => "5", 0x23 => "6", 0x24 => "7", 0x25 => "8",
        0x26 => "9", 0x27 => "0",
        0x28 => "enter", 0x29 => "esc", 0x2a => "backspace",
        0x2b => "tab", 0x2c => "space",
        0x2d => "-", 0x2e => "=", 0x2f => "[", 0x30 => "]",
        0x31 => "\\", 0x33 => ";", 0x34 => "'", 0x35 => "`",
        0x36 => ",", 0x37 => ".", 0x38 => "/",
        0x39 => "caps_lock",
        0x3a => "f1", 0x3b => "f2", 0x3c => "f3", 0x3d => "f4",
        0x3e => "f5", 0x3f => "f6", 0x40 => "f7", 0x41 => "f8",
        0x42 => "f9", 0x43 => "f10", 0x44 => "f11", 0x45 => "f12",
        0x49 => "insert", 0x4a => "home", 0x4b => "page_up",
        0x4c => "delete", 0x4d => "end", 0x4e => "page_down",
        0x4f => "right", 0x50 => "left", 0x51 => "down", 0x52 => "up",
        0x53 => "num_lock"
      }.freeze

      MOUSE_MODE_FLAG = 0x00080000

      attr_reader :bitmask, :modifier_type, :keycode, :string_keys

      def initialize(bitmask:, modifier_type:, keycode:, string_keys: nil)
        @bitmask = bitmask
        @modifier_type = modifier_type
        @keycode = keycode
        @string_keys = string_keys
      end

      def self.from_binary(data, string_table: nil)
        bitmask, modifier_type, keycode = data.unpack("Vvv")
        string_keys = decode_string_keys(modifier_type, string_table)
        new(bitmask: bitmask, modifier_type: modifier_type, keycode: keycode, string_keys: string_keys)
      end

      def to_binary(string_table_offset: nil)
        mod_type = if string_table_offset
          TYPE_MULTICHAR | (string_table_offset << 8)
        else
          modifier_type
        end
        [bitmask, mod_type, keycode].pack("Vvv")
      end

      def type_byte
        modifier_type & 0xFF
      end

      def type_name
        case type_byte
        when TYPE_DEVICE then :device
        when TYPE_KEYBOARD then :keyboard
        when TYPE_MULTICHAR then :multichar
        end
      end

      def modifier_byte
        (modifier_type >> 8) & 0xFF
      end

      def mouse_mode?
        bitmask & MOUSE_MODE_FLAG != 0
      end

      def key_name
        HID_KEYS[keycode]
      end

      def modifier_names
        MODIFIERS.filter_map { |bit, name| name if modifier_byte & bit != 0 }
      end

      def device_function
        DEVICE_FUNCTIONS[modifier_byte] if type_byte == TYPE_DEVICE
      end

      def ==(other)
        other.is_a?(self.class) && to_binary == other.to_binary && string_keys == other.string_keys
      end

      def self.decode_string_keys(modifier_type, string_table)
        return nil unless string_table
        return nil unless (modifier_type & 0xFF) == TYPE_MULTICHAR

        offset = (modifier_type >> 8) & 0xFF
        keys = string_table.read_entry(offset)
        keys.empty? ? nil : keys
      end
      private_class_method :decode_string_keys
    end
  end
end
