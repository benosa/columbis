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

  config.before(:suite) { FactoryGirl.reload }

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
  Time.zone = 'Moscow' # Default time zone
  Faker::Config.locale = :en

  # Rails.logger.level = 4 # reducing the IO and increasing the speed, just comment to log
end

def current_port
  Capybara.current_session.server.port
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

def stub_currents(options)
  user = options[:user]
  company = options[:company] || user.try(:company)
  office = options[:office] || user.try(:office)
  stub_current_user(user) if user
  stub_current_company(company) if company
  stub_current_office(office) if office
end

def factory_assoc(factory, *traits_and_overrides, &block)
  strategy = @build_strategy || :build
  strategy_name = strategy.kind_of?(Symbol) ? srategy : strategy.class.to_s.underscore.split('/').last.downcase.to_sym
  strategy_name = :build if strategy_name == :attributes_for
  FactoryGirl::FactoryRunner.new(factory, strategy_name, traits_and_overrides).run(&block)
end
