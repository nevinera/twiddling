module Twiddling
  module V7
    class StringTable
      attr_reader :data

      def initialize(data = "")
        @data = data.b
      end

      def self.from_entries(entries)
        raw = entries.flat_map { |keys|
          pairs = keys.flat_map { |sk| [sk[:modifier], sk[:hid_code]] }
          pairs + [0, 0]
        }.pack("v*")
        new(raw)
      end

      def read_entry(offset)
        @data[offset..]
          .unpack("v*")
          .each_slice(2)
          .take_while { |mod, hid| mod != 0 || hid != 0 }
          .map { |mod, hid| {modifier: mod, hid_code: hid} }
      end

      def entry_count
        pos = 0
        count = 0
        while pos < @data.length
          mod, hid = @data[pos, 4]&.unpack("vv")
          break unless mod && hid
          count += 1 if mod == 0 && hid == 0
          pos += 4
        end
        count
      end

      def to_binary
        @data
      end
    end
  end
end
