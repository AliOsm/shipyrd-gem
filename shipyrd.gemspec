# frozen_string_literal: true

require_relative "lib/shipyrd/version"

Gem::Specification.new do |spec|
  spec.name = "shipyrd"
  spec.version = Shipyrd::VERSION
  spec.authors = ["Nick Hammond"]
  spec.email = ["nick@shipyrd.io"]

  spec.summary = "The companion gem for Shipyrd, the Kamal deployment dashboard"
  spec.description = "The companion gem for Shipyrd, the Kamal deployment dashboard"
  spec.homepage = "https://shipyrd.io"
  spec.required_ruby_version = ">= 3.0.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shipyrd/shipyrd-gem"
  spec.metadata["changelog_uri"] = "https://github.com/shipyrd/shipyrd-gem/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git])
    end
  end

  spec.bindir = "bin"
  spec.require_paths = ["lib"]
end
