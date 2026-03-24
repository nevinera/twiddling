module Twiddling
  module V7
    # Constants shared between Chord, Reader::Chord, and Writer::Chord.
    module ChordConstants
      ENTRY_SIZE = 8

      # Chord type (low byte of modifier_type)
      TYPE_DEVICE = 0x01
      TYPE_KEYBOARD = 0x02
      TYPE_MULTICHAR = 0x07

      # Keyboard modifier bits (high byte of modifier_type when type = 0x02)
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

      # Device function codes (high byte of modifier_type when type = 0x01)
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

      # USB HID keycodes -> key names
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

      # Base key -> shifted symbol (for Shift+key display)
      SHIFTED_KEYS = {
        "1" => "!", "2" => "@", "3" => "#", "4" => "$",
        "5" => "%", "6" => "^", "7" => "&", "8" => "*",
        "9" => "(", "0" => ")",
        "-" => "_", "=" => "+", "[" => "{", "]" => "}",
        "\\" => "|", ";" => ":", "'" => '"', "`" => "~",
        "," => "<", "." => ">", "/" => "?"
      }.freeze

      # Characters that need special handling in string output
      KEY_TO_CHAR = {"space" => " ", "tab" => "\t"}.freeze

      MOUSE_MODE_FLAG = 0x00080000
    end
  end
end
