# -*- encoding : utf-8 -*-
set :branch, "develop"

set :application, "columbis-dev"
set(:deploy_to) { "/opt/apps/#{application}" }

set :domain, "192.241.134.125"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :rails_env, "staging"
set :unicorn_env, "dev"

require 'capistrano-unicorn'