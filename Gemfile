# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in shiftable.gemspec
gemspec

plugin "diffend"
# Monitor is required for production realtime notifications
gem "diffend-monitor", require: %w[diffend/monitor]

ruby_version = Gem::Version.new(RUBY_VERSION)
minimum_version = ->(version) { ruby_version >= Gem::Version.new(version) && RUBY_ENGINE == "ruby" }
actual_version = lambda do |major, minor|
  actual = Gem::Version.new(ruby_version)
  major == actual.segments[0] && minor == actual.segments[1] && RUBY_ENGINE == "ruby"
end
coverage = actual_version.call(2, 6)
linting = minimum_version.call("2.6")

if linting
  gem "rubocop", "~> 1.22"
  gem "rubocop-faker", "~> 1.1"
  gem "rubocop-md", "~> 1.0"
  gem "rubocop-minitest", "~> 0.15"
  gem "rubocop-packaging", "~> 0.5"
  gem "rubocop-performance", "~> 1.11"
  gem "rubocop-rake", "~> 0.6"
  gem "rubocop-rspec", "~> 2.5"
  gem "rubocop-thread_safety", "~> 0.4"
end

if coverage
  gem "codecov", "~> 0.6"
  gem "simplecov", "~> 0.21"
  gem "simplecov-cobertura", "~> 2.1"
end
