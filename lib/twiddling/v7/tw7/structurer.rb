module Twiddling
  module V7
    module Tw7
      # Reads raw .tw7 text and builds a ConfigData: an array of SettingsLine
      # objects and a nested tree of ChordLine / ChordScopeLine objects.
      class Structurer
        DIVIDER = /\A={5,}\z/

        def initialize(text)
          @text = text
        end

        def structure
          numbered = strip_comments(number_lines(@text.lines))
          settings_raw, chords_raw = split_sections(numbered)
          ConfigData.new(
            settings_lines: build_settings_lines(settings_raw),
            chord_lines: build_chord_tree(chords_raw)
          )
        end

        private

        def number_lines(lines)
          lines.each_with_index.map { |line, idx| [idx + 1, line.rstrip] }
        end

        def strip_comments(numbered)
          numbered.map { |num, line| [num, strip_line_comment(line)] }
        end

        def strip_line_comment(line)
          in_quotes = false
          line.each_char.with_index do |ch, i|
            if ch == '"'
              in_quotes = !in_quotes
            elsif ch == "#" && !in_quotes
              return line[0, i].rstrip
            end
          end
          line
        end

        def split_sections(numbered)
          divider_idx = numbered.index { |_, line| line.match?(DIVIDER) }
          if divider_idx
            [numbered[0...divider_idx], numbered[(divider_idx + 1)..]]
          else
            [[], numbered]
          end
        end

        def build_settings_lines(numbered)
          numbered
            .reject { |_, line| line.strip.empty? }
            .map { |num, line| SettingsLine.new(line_number: num, line_text: line.strip) }
        end

        def build_chord_tree(numbered)
          root = []
          stack = [[-1, root]]
          numbered.each { |num, line| add_chord_item(num, line, stack) }
          root
        end

        def add_chord_item(num, line, stack)
          return if line.strip.empty?
          depth = indent_depth(line)
          content = line.strip
          stack.pop while stack.last[0] >= depth
          push_chord_node(num, content, depth, stack)
        end

        def push_chord_node(num, content, depth, stack)
          if content.end_with?("::")
            scope = ChordScopeLine.new(line_number: num, line_text: content)
            stack.last[1] << scope
            stack.push([depth, scope.children])
          else
            stack.last[1] << ChordLine.new(line_number: num, line_text: content)
          end
        end

        def indent_depth(line)
          line.match(/\A(\s*)/)[1].length
        end
      end
    end
  end
end
