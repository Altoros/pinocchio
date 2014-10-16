ENV["RAILS_ENV"] ||= 'test'

require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require "rack/test"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Capybara.server_port = 9888

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include(FactoryGirl::Syntax::Methods)
  config.include(LoginMacros)
  config.include RequestsHelpers
  config.infer_base_class_for_anonymous_controllers = true
  config.order = 'random'
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.color = true

  config.infer_spec_type_from_file_location!

  config.include Rack::Test::Methods

  # Use transactions by default
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Switch to truncation for javascript tests, but only clean used tables
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
