# -*- encoding : utf-8 -*-
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'thinking_sphinx/test'
require File.dirname(__FILE__) + '/activerecord_shared_connection'
require File.dirname(__FILE__) + "/macros"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true

  config.include Macros
  config.include Devise::TestHelpers, :type => :controller
  config.include FactoryGirl::Syntax::Methods

  Capybara.default_wait_time = 5
  Capybara.register_driver :poltergeist do |app|
    options = {
      timeout: 5,
      window_size: [1024, 768]
    }
    Capybara::Poltergeist::Driver.new(app, options)
  end
  Capybara.javascript_driver = :poltergeist

  ThinkingSphinx::Test.init

  # Rails.logger.level = 4 # reducing the IO and increasing the speed, just comment to log
end

def test_sign_in(user)
  sign_in(user)
end

def stub_current_user(user)
  controller.stub!(:current_user).and_return(user)
end
