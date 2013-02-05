# -*- encoding : utf-8 -*-
set :branch, "staging"

set :application, "tourism-dev"
set(:deploy_to) { "/opt/apps/#{application}" }

set :domain, "tourism-dev.devmen.com"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

require 'capistrano-unicorn'
