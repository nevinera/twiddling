module Twiddling
  module V7
    class StringTable
      attr_reader :entries

      def initialize(entries = [])
        @entries = entries
      end

      def entry_at_offset(byte_offset)
        offset_lookup[byte_offset]
      end

      private

      def offset_lookup
        @offset_lookup ||= entries.to_h { |e| [e.byte_offset, e] }
      end
    end
  end
end
