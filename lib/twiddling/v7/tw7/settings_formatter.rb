module Twiddling
  module V7
    module Tw7
      # Formats the settings section of a .tw7 file.
      # Only emits settings that differ from defaults.
      module SettingsFormatter
        include ConfigConstants

        DEFAULTS = {
          idle_time: 600,
          key_repeat_delay: 100,
          key_repeat: true,
          haptic: true,
          keyboard_mode: false,
          nav_sensitivity: 4,
          nav_invert_x: false,
          nav_direction: 0,
          t1_modifier: :num,
          t2_modifier: :l_option,
          t3_modifier: :l_control,
          t4_modifier: :l_shift,
          f0l_dedicated: :mouse_right,
          f0m_dedicated: :mouse_middle,
          f0r_dedicated: :mouse_left,
          t0_dedicated: :mouse_left
        }.freeze

        module_function

        def format(config)
          current = extract_settings(config)
          lines = []

          current.each do |key, value|
            next if DEFAULTS[key] == value
            lines << "#{key}: #{format_value(value)}"
          end

          lines
        end

        def extract_settings(config)
          extract_header_settings(config)
            .merge(extract_thumb_settings(config))
            .merge(extract_dedicated_settings(config))
        end

        def extract_header_settings(config)
          extract_timing_settings(config).merge(extract_flag_settings(config))
        end

        def extract_timing_settings(config)
          {idle_time: config.idle_time, key_repeat_delay: config.key_repeat}
        end

        def extract_flag_settings(config)
          {
            key_repeat: (config.flags_1 & 0x01) != 0,
            haptic: (config.flags_1 & 0x08) != 0,
            keyboard_mode: (config.flags_1 & 0x02) != 0,
            nav_sensitivity: (config.flags_2 >> 3) & 0x1F,
            nav_invert_x: (config.flags_2 & 0x04) != 0,
            nav_direction: config.flags_2 & 0x03
          }
        end

        def extract_thumb_settings(config)
          {
            t1_modifier: THUMB_MODIFIERS[config.thumb_modifiers[0]],
            t2_modifier: THUMB_MODIFIERS[config.thumb_modifiers[1]],
            t3_modifier: THUMB_MODIFIERS[config.thumb_modifiers[2]],
            t4_modifier: THUMB_MODIFIERS[config.thumb_modifiers[3]]
          }
        end

        def extract_dedicated_settings(config)
          {
            f0l_dedicated: DEDICATED_FUNCTIONS[config.dedicated_buttons[0]],
            f0m_dedicated: DEDICATED_FUNCTIONS[config.dedicated_buttons[1]],
            f0r_dedicated: DEDICATED_FUNCTIONS[config.dedicated_buttons[2]],
            t0_dedicated: DEDICATED_FUNCTIONS[config.dedicated_buttons[3]]
          }
        end

        def format_value(value)
          case value
          when true then "true"
          when false then "false"
          when Symbol then value.to_s
          else value.to_s
          end
        end
      end
    end
  end
end
