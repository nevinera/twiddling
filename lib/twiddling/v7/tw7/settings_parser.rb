module Twiddling
  module V7
    module Tw7
      # Parses the settings section of a .tw7 file into Config attributes.
      module SettingsParser
        include ConfigConstants

        THUMB_MODIFIER_NAMES = THUMB_MODIFIERS.to_h { |code, name| [name.to_s, code] }.freeze
        DEDICATED_NAMES = DEDICATED_FUNCTIONS.to_h { |code, name| [name.to_s, code] }.freeze

        module_function

        # Returns a hash of Config-compatible attributes from settings lines.
        # Missing settings use defaults from the empty.cfg baseline.
        def parse(lines)
          raw = parse_lines(lines)
          build_attrs(raw)
        end

        private

        def parse_lines(lines)
          lines.each_with_object({}) do |line, hash|
            key, value = line.split(":", 2).map(&:strip)
            hash[key] = value
          end
        end

        def build_attrs(raw) # rubocop:disable Metrics/AbcSize
          {
            idle_time: int_val(raw, "idle_time", 600),
            key_repeat: int_val(raw, "key_repeat_delay", 100),
            flags_1: build_flags_1(raw),
            flags_2: build_flags_2(raw),
            thumb_modifiers: build_thumb_modifiers(raw),
            dedicated_buttons: build_dedicated(raw)
          }
        end

        def build_flags_1(raw)
          flags = 0
          flags |= 0x01 if bool_val(raw, "key_repeat", true)
          flags |= 0x02 if bool_val(raw, "keyboard_mode", false)
          flags |= 0x08 if bool_val(raw, "haptic", true)
          flags
        end

        def build_flags_2(raw)
          sensitivity = int_val(raw, "nav_sensitivity", 4)
          invert_x = bool_val(raw, "nav_invert_x", false) ? 1 : 0
          direction = int_val(raw, "nav_direction", 0)
          (sensitivity << 3) | (invert_x << 2) | direction
        end

        def build_thumb_modifiers(raw)
          [
            thumb_val(raw, "t1_modifier", :none),
            thumb_val(raw, "t2_modifier", :l_option),
            thumb_val(raw, "t3_modifier", :l_control),
            thumb_val(raw, "t4_modifier", :l_shift)
          ]
        end

        def build_dedicated(raw)
          [
            dedicated_val(raw, "f0l_dedicated", :mouse_right),
            dedicated_val(raw, "f0m_dedicated", :mouse_middle),
            dedicated_val(raw, "f0r_dedicated", :mouse_left),
            dedicated_val(raw, "t0_dedicated", :mouse_left)
          ]
        end

        def int_val(raw, key, default)
          raw.key?(key) ? raw[key].to_i : default
        end

        def bool_val(raw, key, default)
          raw.key?(key) ? raw[key] == "true" : default
        end

        def thumb_val(raw, key, default)
          name = raw.key?(key) ? raw[key] : default.to_s
          THUMB_MODIFIER_NAMES[name.to_s] || raise(ArgumentError, "Unknown thumb modifier: #{name}")
        end

        def dedicated_val(raw, key, default)
          name = raw.key?(key) ? raw[key] : default.to_s
          DEDICATED_NAMES[name.to_s] || raise(ArgumentError, "Unknown dedicated function: #{name}")
        end

        module_function :parse_lines, :build_attrs, :build_flags_1, :build_flags_2,
          :build_thumb_modifiers, :build_dedicated, :int_val, :bool_val,
          :thumb_val, :dedicated_val
      end
    end
  end
end
