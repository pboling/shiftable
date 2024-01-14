# frozen_string_literal: true

require_relative "lib/shiftable/version"

Gem::Specification.new do |spec|
  spec.name = "shiftable"
  spec.version = Shiftable::VERSION
  spec.authors = ["Peter Boling"]
  spec.email = ["peter.boling@gmail.com"]

  spec.summary = "Easily shift record associations"
  spec.description = "Move single records (has_one) or collections (has_many) from one parent (belongs_to) to another"
  spec.homepage = "https://railsbling.com/tags/shiftable"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pboling/shiftable"
  spec.metadata["changelog_uri"] = "https://github.com/pboling/shiftable/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*.rb", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "LICENSE.txt", "README.md"]
  spec.bindir = "exe"
  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5"
  spec.add_development_dependency "activerecord-transactionable", ">= 3"
  spec.add_development_dependency "byebug", "~> 11.1"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.0"
  spec.add_development_dependency "factory_bot", "~> 6.2"
  spec.add_development_dependency "faker", "~> 3.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rspec-benchmark", "~> 0.6"
  spec.add_development_dependency "rspec-block_is_expected", "~> 1.0"
  spec.add_development_dependency "silent_stream", "~> 1"
  spec.add_development_dependency "sqlite3", "~> 1"
  spec.add_development_dependency "yard", ">= 0.9.20"
end
