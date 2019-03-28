# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ENV['DB'] ||= 'sqlite'

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

unless File.exist?(File.expand_path('dummy_app/config/database.yml', __dir__))
  warn 'WARNING: No database.yml detected for the dummy app, please run `rake prepare` first'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Support for disabling `verify_partial_doubles` on specific examples.
  config.around(:each, verify_stubs: false) do |ex|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = false
      ex.run
      mocks.verify_partial_doubles = true
    end
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.warnings = false
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end

def active_record_gem_version
  Gem::Version.new(ActiveRecord::VERSION::STRING)
end

# Wrap args in a hash to support the ActionController::TestCase and
# ActionDispatch::Integration HTTP request method switch to keyword args
# (see https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md)
def params_wrapper(args)
  if defined?(::Rails) && active_record_gem_version >= Gem::Version.new('5.0.0.beta1')
    { params: args }
  else
    args
  end
end

require File.expand_path('dummy_app/config/environment', __dir__)
require 'rspec/rails'
require 'ffaker'
require 'timecop'

# Run any available migration
::ActiveRecord::MigrationContext.new(File.expand_path('dummy_app/db/migrate/', __dir__)).migrate

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = active_record_gem_version >= ::Gem::Version.new('5')

  # In rails < 5, some tests seem to require DatabaseCleaner-truncation.
  # Truncation is about three times slower than transaction rollback, so it'll
  # be nice when we can drop support for rails < 5.
  if active_record_gem_version < ::Gem::Version.new('5')
    config.before(:each) { DatabaseCleaner.start }
    config.after(:each) { DatabaseCleaner.clean }
  end
end
