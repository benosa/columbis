# -*- encoding : utf-8 -*-
set :branch, "production"

set :application, "columbis"
set(:deploy_to) { "/opt/apps/#{application}" }

set :domain, "188.226.190.90"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :rvm_ruby_string, "2.0.0-p451@columbis"
set :rvm_type, :user

set :rails_env, "production"

require 'capistrano-unicorn'