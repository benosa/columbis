# -*- encoding : utf-8 -*-
Tourism::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  config.cache_store = :file_store, Rails.root.join('tmp/cache')

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

# just for debugging timepicker
#  # Compress JavaScripts and CSS
#  config.assets.compress = true

#  # Don't fallback to assets pipeline if a precompiled asset is missed
#  config.assets.compile = true

#  # Generate digests for assets URLs
#  config.assets.digest = true

  config.action_mailer.default_url_options = { host: 'localhost' }
  # config.action_mailer.delivery_method = :letter
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  # mailcather options
  config.action_mailer.smtp_settings = {
    :address              => 'localhost',
    :port                 => 1025
  }
  # config.action_mailer.smtp_settings = {
  #   :address              => 'smtp.gmail.com',
  #   :port                 => 587,
  #   :domain               => 'gmail.com',
  #   :user_name            => 'testdevmen@gmail.com',
  #   :password             => '20081989',
  #   :authentication       => 'plain',
  #   :enable_starttls_auto => true
  # }

  # Thinking sphinx starter
  # unless defined?(IRB)
  #   config.after_initialize do
  #     require 'rake'
  #     Tourism::Application.load_tasks
  #     # Rake::Task['ts:start'].reenable # in case you're going to invoke the same task second time.
  #     Rake::Task['ts:start'].invoke
  #   end
  # end

end
