module Twiddling
  module V7
    # Constants shared between Config, Reader::Config, and Writer::Config.
    module ConfigConstants
      HEADER_SIZE = 128

      # Button bitmask bit positions (bits 0-18 of chord bitmask)
      BUTTON_BITS = {
        0 => :T1, 1 => :F1L, 2 => :F1M, 3 => :F1R,
        4 => :T2, 5 => :F2L, 6 => :F2M, 7 => :F2R,
        8 => :T3, 9 => :F3L, 10 => :F3M, 11 => :F3R,
        12 => :T4, 13 => :F4L, 14 => :F4M, 15 => :F4R,
        16 => :F0L, 17 => :F0M, 18 => :F0R
      }.freeze

      # Thumb button modifier assignment codes (offsets 0x40-0x4F)
      THUMB_MODIFIERS = {
        0 => :num, 1 => :l_control, 2 => :l_shift,
        3 => :l_option, 4 => :l_command
      }.freeze

      # Dedicated button function codes (offsets 0x50-0x53)
      DEDICATED_FUNCTIONS = {
        0x00 => :none, 0x09 => :mouse_left,
        0x0a => :mouse_right, 0x0b => :mouse_middle
      }.freeze
    end
  end
end
