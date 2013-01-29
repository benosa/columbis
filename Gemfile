source 'http://rubygems.org'

gem 'rails', '~> 3.2.11'
gem 'pg', '~> 0.14.1'

gem 'haml', '~> 3.1.7'
# Using haml-rails, because haml gem dosn't give generators for rails 3
gem 'haml-rails', '~> 0.3.5'

gem 'cancan', '~> 1.6.8'
gem 'devise', '~> 2.1.2'

gem 'jquery-rails', '~> 2.1.4'

gem 'will_paginate', '~> 3.0'
gem 'rails3-jquery-autocomplete', '~> 1.0.10'
# gem 'ru_propisju', :git => 'https://github.com/terraplane/ru_propisju.git'
gem 'ru_propisju', '~> 2.1.4'
# gem 'stringex'
gem 'russian', '~> 0.6.0'

gem 'thinking-sphinx', '2.0.14'
gem 'carrierwave', '0.8.0'
gem 'smt_rails', '~> 0.2.4'
gem 'best_in_place', '~> 2.0.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'hogan_assets'
  gem 'haml_assets'
  gem 'libv8', '~> 3.11.8' # workaround to avoid issues with compiled libv8
  gem 'therubyracer', '~> 0.11.0', :require => 'v8' # requires libv8
end

group :development do
  # gem 'passenger'
  gem 'rails_best_practices', '~> 1.13.2'
  gem 'capistrano', :require => false
  gem 'rvm-capistrano', :require => false
  gem 'capistrano_colors', :require => false
  gem 'annotate', '~> 2.5.0'
  gem 'meta_request', '~> 0.2.1'
  gem 'rack-mini-profiler', '~> 0.1.23'
end

group :development, :test do
  # gem 'turn', :require => false
  gem 'rspec-rails', '~> 2.12.0'
  gem 'capybara', '~> 1.1.4' # don't use 2 version, because poltergeist relies on capybara ~> 1.1
  gem 'poltergeist', '~> 1.0.2' # need to install phantomjs (http://phantomjs.org/download.html)
  gem 'launchy', '~> 2.1.2'
  gem 'database_cleaner', '0.9.1'
  gem 'rails3-generators', '1.0.0'
  gem 'factory_girl_rails', '~> 4.1.0' #, :require => false
  gem 'faker', '1.1.2'
  gem 'hirb', '0.7.0'

  case RbConfig::CONFIG['host_os']
    when /darwin/i
      gem 'rb-fsevent'
      gem 'growl'
    when /linux/i
      gem 'libnotify'
      gem 'rb-inotify'
    when /mswin|windows/i
      gem 'rb-fchange'
      gem 'win32console'
      gem 'rb-notifu'
  end

  gem 'guard', '~> 1.6.0'
  gem 'guard-bundler', '>= 1.0.0'
  gem 'guard-rails', '>= 0.1.1'
  gem 'guard-rspec', '~> 2.3.3'
  # gem 'guard-livereload', '~> 1.1.3'
end

group :test do
  gem 'shoulda', '~> 3.3.2'
  gem 'email_spec', '~> 1.4.0'
end

group :production do
  gem 'exception_notification', '~> 3.0.0' #, :group => %w(staging staging2)
end
