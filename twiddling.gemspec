require_relative "lib/twiddling/version"

Gem::Specification.new do |spec|
  spec.name = "twiddling"
  spec.version = Twiddling::VERSION
  spec.authors = ["Eric Mueller"]
  spec.email = ["nevinera@gmail.com"]

  spec.summary = "A cli tool for reading/writing/editing Twiddler v7 configuration files"
  spec.description = <<~DESC
    Edit twiddler4 (v7) configuration files as text, rather than using the clunky online tool.

    Adding a full configuration by hand is _extremely_ tedious, and you shouldn't have to do i.
  DESC
  spec.homepage = "https://github.com/nevinera/twiddling"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.3.8")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.require_paths = ["lib"]
  spec.bindir = "bin"
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.start_with?("spec") }
  end
  spec.executables = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z bin/`
      .split("\x0")
      .map { |path| path.sub(/^bin\//, "") }
  end

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rspec-its", "~> 1.3"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "standard", ">= 1.35.1"
  spec.add_development_dependency "rubocop", ">= 1.62"
  spec.add_development_dependency "debug", "~> 1.7"
  spec.add_development_dependency "mdl", "~> 0.12"
  spec.add_development_dependency "quiet_quality", "~> 1.5"

  spec.add_dependency "bindata", "~> 2.5"
end
