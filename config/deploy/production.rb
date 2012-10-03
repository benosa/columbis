# set :branch, "master"

set :application, "tourism"
set(:deploy_to) { "/opt/apps/#{application}" }

set :domain, "tourism.devmen.com"
set :port, 22

role :app, domain
role :web, domain
role :db,  domain, :primary => true
