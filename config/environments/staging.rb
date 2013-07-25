# -*- encoding : utf-8 -*-
Tourism::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false # enable while web server is not configured properly

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  config.cache_store = :file_store, Rails.root.join('tmp/cache')

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( jquery-ui.css new_design/css/low.css new_design/css/middle.css new_design/css/high.css common.css css3-mediaqueries.js )
  config.assets.precompile += %w( boss.css boss.js ) # boss assets

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Mail delivery settings
  begin
    mailer_config = YAML::load_file(Rails.root.join "config/mailer.yml")[Rails.env]

    config.action_mailer.default_url_options = { :host => mailer_config['smtp_settings']['domain'] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = false
    config.action_mailer.default :charset => "utf-8"
    config.action_mailer.smtp_settings = mailer_config['smtp_settings'].symbolize_keys

    # Exception notification settings
    config.middleware.use ExceptionNotifier, mailer_config['exception_notification'].symbolize_keys
      # :email_prefix => "[#{mailer_config['exception_notification']['email_prefix']}] ",
      # :sender_address => %{ "Notifier" <#{mailer_config['smtp_settings']['user_name']}> },
      # :exception_recipients => mailer_config['exception_notification']['recipients']
  rescue Exception => e
    # No mailer config or it's incorrect
  end
end
