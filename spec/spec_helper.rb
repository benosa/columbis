# -*- encoding : utf-8 -*-
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require File.dirname(__FILE__) + "/macros"
require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  config.before(:suite) { DatabaseCleaner.strategy = :truncation }
  # config.before(:each)  { DatabaseCleaner.start }
  # config.after(:each)   { DatabaseCleaner.clean }
  config.before(:each) do
    if Capybara.current_driver == :webkit || Capybara.current_driver == :poltergeist
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include(Macros)
  config.include Devise::TestHelpers, :type => :controller

  # MODULES.each do |m|
  #   module_macros = "#{m.camelize}::Macros".constantize rescue nil
  #   config.include(module_macros) if module_macros
  # end

  Capybara.default_wait_time = 5
  #Capybara.javascript_driver = :webkit
  Capybara.javascript_driver = :poltergeist
end

def test_sign_in(user)
  sign_in(user)
end

def stub_current_user(user)
  controller.stub!(:current_user).and_return(user)
end
