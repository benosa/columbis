# -*- encoding : utf-8 -*-
# set :branch, "master"

set :application, "tourism-dev"
set(:deploy_to) { "/opt/apps/#{application}" }

set :domain, "tourism-dev.devmen.com"
set :port, 22

role :app, domain
role :web, domain
role :db,  domain, :primary => true
