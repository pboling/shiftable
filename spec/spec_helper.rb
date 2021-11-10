# frozen_string_literal: true

# External Gems
require "faker"
require "byebug"
require "rspec/block_is_expected"

# Code coverage
require "simplecov"
require "simplecov-cobertura"
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter unless ENV["HTML_COVERAGE"] == "true"

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

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
