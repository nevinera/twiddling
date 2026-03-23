module Twiddling
  module V7
    class StringTableEntry
      attr_reader :keys, :byte_offset

      def initialize(keys:, byte_offset:)
        @keys = keys
        @byte_offset = byte_offset
      end

      def byte_size = (keys.length + 1) * 4
    end
  end
end
