# -*- encoding : utf-8 -*-
set :branch, "master"

set :application, "tourism-dev2"
set(:deploy_to) { "/opt/apps/#{application}" }

set :domain, "tourism-dev2.devmen.com"

# set :scm, :none
set :repository, '.'
set :deploy_via, :copy

role :app, domain
role :web, domain
role :db,  domain, :primary => true
