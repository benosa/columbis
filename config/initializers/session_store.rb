# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

Tourism::Application.config.session_store :cookie_store,
	:key => CONFIG[:session_key] || '_columbis_session',
	:domain => CONFIG[:domain] unless Rails.env.development?

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Tourism::Application.config.session_store :active_record_store