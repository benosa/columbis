# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# Application configuration
CONFIG = (YAML.load_file(File.expand_path('../application.yml', __FILE__))[Rails.env] || {}).with_indifferent_access

module Tourism
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %w[#{config.root}/lib #{config.root}/app/delayed_jobs]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :claim_sweeper

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru
    config.i18n.available_locales = [:ru, :en]
    # Workaround for I18n.locale setting issue
    I18n.locale = config.i18n.locale = config.i18n.default_locale

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.to_prepare do
      Devise::SessionsController.layout proc{ |controller| action_name == 'new' ? "public" : "application" }
      Devise::RegistrationsController.layout proc{ |controller| user_signed_in? ? "application" : "public" }
      Devise::ConfirmationsController.layout "public"
      Devise::UnlocksController.layout "public"
      Devise::PasswordsController.layout "public"
    end

    # Generators by default
    config.generators do |g|
      g.test_framework :rspec,
        fixture: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.template_engine :haml
    end

    # Enabling HTTPS and HTTP in parallel
    config.middleware.insert_before ActionDispatch::Static, Rack::SSL, :exclude => proc { |env| env['HTTPS'] != 'on' }

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # For extending models with search_and_sort method
    require 'search_and_sort'

    # Special module for Mistral
    require 'mistral'

  end
end
