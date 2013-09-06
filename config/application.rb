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
    config.autoload_paths += %W(#{config.root}/lib)

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

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Use custom html wrapper for field with errors
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      errors = Array(instance.error_message).join(', ')
      if html_tag =~ /^<label/
        html_tag #TODO: temporary solution until the new liquid layouts
        # %(<span class="error_message">#{html_tag}</span>).html_safe
      else
        cls = html_tag[/class="(.+?)"/, 1]
        id = html_tag[/id="(.+?)"/, 1] + '_wrapper'
        %(<div id="#{id}" class="error_message input_wrapper" title="#{errors}">#{html_tag}</div>).html_safe
      end
    end

    # For extending models with search_and_sort method
    require 'search_and_sort'

  end
end
