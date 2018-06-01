require "rails_helper"

RSpec.configure do |config|
  Capybara.javascript_driver = :webkit

  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include FeatureMacros, type: :feature

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

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
