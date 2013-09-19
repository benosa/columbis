# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

session_options = { :key => CONFIG[:session_key] || '_columbis_session' }
session_options[:domain] = ".#{CONFIG[:domain]}" unless CONFIG[:domain] == 'localhost' # .columbis.ru - for all subdomains
Tourism::Application.config.session_store :cookie_store, session_options

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Tourism::Application.config.session_store :active_record_store