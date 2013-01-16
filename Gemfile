source 'http://rubygems.org'

gem 'rails', '3.1.3'

gem 'pg'
gem 'haml'
gem 'rack', '1.3.5'

gem 'devise'
gem 'cancan'

gem 'jquery-rails', '1.0.19'

gem 'will_paginate', '~> 3.0'
gem 'rails3-jquery-autocomplete', '~> 1.0.9'
gem 'ru_propisju', :git => 'https://github.com/terraplane/ru_propisju.git'
gem 'stringex'
gem 'russian', '~> 0.6.0'

gem 'thinking-sphinx', '2.0.13'
gem 'carrierwave'
gem 'smt_rails', '~> 0.2.1'
gem 'best_in_place', '~> 2.0.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
  gem 'hogan_assets'
  gem 'haml_assets'
  gem 'therubyracer', '~> 0.10.2', :platforms => [:mri, :rbx]
end

group :development do
  gem 'mongrel', '>= 1.2.0.pre2'
  gem 'passenger'
  gem 'nifty-generators'
  gem 'capistrano', :require => false
  gem 'rvm-capistrano', :require => false
  gem 'capistrano_colors', :require => false
  gem 'annotate'
end

group :development, :test do
  gem 'ffaker',                   '~> 1.5'
  gem 'rspec-rails',              '~> 2.7.0'
end

group :test do
  gem 'turn', :require => false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group :production do
  gem 'exception_notification', :git => 'https://github.com/smartinez87/exception_notification.git', :group => %w(staging staging2)
end
