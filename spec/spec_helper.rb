# frozen_string_literal: true

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == "ruby" }
actual_version = lambda do |major, minor|
  actual = Gem::Version.new(ruby_version)
  major == actual.segments[0] && minor == actual.segments[1] && RUBY_ENGINE == "ruby"
end
coverage = actual_version.call(2, 6)
debug = minimum_version.call("2.4")

require "simplecov" if coverage

# External libraries
require "byebug" if debug
require "faker"
require "rspec/block_is_expected"

# This gem
require "shiftable"

# Configs
require "config/active_record"
require "config/factory_bot"
require "rspec_config/database_cleaner"
require "rspec_config/factory_bot"
require "rspec_config/matchers"
require "shared_examples/factories"
require "shared_examples/shiftable_single"
require "shared_examples/shiftable_collection"
require "shared_examples/shiftable_polymorphic_collection"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
