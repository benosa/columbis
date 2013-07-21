# -*- encoding : utf-8 -*-
set :branch, "master"

set :application, "columbis"
set(:deploy_to) { "/opt/apps/#{application}" }

set :domain, "columbis.ru"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :rails_env, "production"

require 'capistrano-unicorn'