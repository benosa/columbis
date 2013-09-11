# -*- encoding : utf-8 -*-

# Test coverage framework
if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'thinking_sphinx/test'
require 'database_cleaner'
require File.dirname(__FILE__) + '/activerecord_shared_connection'
require File.dirname(__FILE__) + '/macros'
require File.dirname(__FILE__) + '/matchers'
require File.dirname(__FILE__) + '/database_cleaner_config'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  config.include Macros
  config.include Matchers
  config.include Devise::TestHelpers, :type => :controller
  config.include FactoryGirl::Syntax::Methods

  Capybara.default_wait_time = 5
  Capybara.ignore_hidden_elements = false
  Capybara.register_driver :poltergeist do |app|
    options = {
      timeout: 5,
      cookies: true,
      js_errors: false,
      window_size: [1024, 768]
    }
    Capybara::Poltergeist::Driver.new(app, options)
  end
  Capybara.javascript_driver = :poltergeist

  ThinkingSphinx::Test.init

  Rails.logger.level = 4 # reducing the IO and increasing the speed, just comment to log
end

Time.zone = 'Moscow' # Default time zone
Faker::Config.locale = :en

def current_port
  current_url.split(':')[2].split('/')[0]
end

def test_sign_in(user)
  sign_in(user)
end

def stub_current_user(user)
  controller.stub!(:current_user).and_return(user)
end

def stub_current_company(company)
  controller.stub!(:current_company).and_return(company)
end

def stub_current_office(office)
  controller.stub!(:current_office).and_return(office)
end
