require "bindata"

module Twiddling
  Error = Class.new(StandardError)
end

require_relative "twiddling/v7"
require_relative "twiddling/cli"
