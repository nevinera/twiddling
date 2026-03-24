require "rspec"
require "rspec/its"
require "pry"

if ENV["SIMPLECOV"]
  require "simplecov"

  class ProblemsFormatter
    def format(result)
      problems = find_problems(result)
      problems.any? ? report_problems(problems) : warn("All files fully covered")
    end

    private

    def find_problems(result)
      all_files = result.groups.any? ? result.groups.flat_map { |_, files| files } : result.files
      all_files.select { |f| f.covered_percent < 100.0 }
    end

    def report_problems(files)
      warn "Coverage gaps:"
      files.each do |f|
        lines = f.missed_lines.map(&:line_number).join(", ")
        warn "  #{f.filename} (#{f.covered_percent.round(2)}%) - lines: #{lines}"
      end
    end
  end

  SimpleCov.start do
    formatter(ProblemsFormatter) if ENV["SIMPLECOV_TEXT"]
    minimum_coverage line: 100
    add_filter "spec/"
  end
end

gem_root = File.expand_path("../..", __FILE__)
FIXTURES_DIRECTORY = File.join(gem_root, "fixtures")
TEMP_DIRECTORY = File.join(gem_root, "tmp")

require File.expand_path("../../lib/twiddling", __FILE__)

support_glob = File.join(gem_root, "spec", "support", "**", "*.rb")
Dir[support_glob].sort.each { |f| require f }

def fixture_path(*parts)
  File.join(FIXTURES_DIRECTORY, *parts)
end

def fixture_content(*parts)
  File.read(fixture_path(*parts))
end

def fixture_json(*parts)
  JSON.parse(fixture_content(*parts))
end

def tmp_path(*parts)
  File.join(TEMP_DIRECTORY, *parts)
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec
  config.order = "random"
  config.tty = true
end
