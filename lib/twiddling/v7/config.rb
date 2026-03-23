module Twiddling
  module V7
    class Config
      include ConfigConstants

      ATTR_NAMES = %i[
        version format_version flags_1 flags_2 flags_3
        idle_time key_repeat reserved_0e reserved_10
        thumb_modifiers dedicated_buttons reserved_54
        index_table chords
      ].freeze

      attr_reader(*ATTR_NAMES)

      def initialize(attrs)
        ATTR_NAMES.each { |name| instance_variable_set(:"@#{name}", attrs[name]) }
      end

      def self.from_file(path) = Reader::Config.new(File.binread(path)).parse

      def self.from_binary(data) = Reader::Config.new(data).parse

      def to_binary = Writer::Config.new(self).to_binary

      def write(path) = File.binwrite(path, to_binary)

      def chord_count = chords.length
    end
  end
end
