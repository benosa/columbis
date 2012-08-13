require 'bundler/capistrano'
require 'thinking_sphinx/deploy/capistrano'

set :application, 'tourism'
set :repository,  "git@devmen.unfuddle.com:devmen/tourism.git"

set :scm, :git

role :app, "devmen.com"
role :web, "devmen.com"
role :db,  "devmen.com", :primary => true

set :deploy_to, "/opt/apps/tourism"
set :user, "deploy"
set :use_sudo, false
set :rails_env, "production"
set :shared_host, "tourism.devmen.com"

before "deploy:update_code", "thinking_sphinx:stop"
after "deploy:update_code", "deploy:config"
after "deploy:update_code", "deploy:uploads"
after "deploy:update_code", "deploy:migrate"
#after "deploy:migrate", "deploy:seed"

#after "deploy:update_code", "deploy:repair_sequences"
after "deploy:update_code", "thinking_sphinx:configure"
after "deploy:update_code", "thinking_sphinx:index"
after "deploy:update_code", "thinking_sphinx:start"
after "thinking_sphinx:start", "deploy:create_manifest"

namespace :deploy do
  task :start do
  end

  task :stop do
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :config do
    run "cd #{release_path}/config && ln -s #{shared_path}/config/database.yml database.yml"
  end

  task :uploads do
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end

  desc "secuenses changes when need generate new value for relaten table"
  task :repair_sequences do
    run "cd #{current_path}; bundle exec rake repair:sequences RAILS_ENV=#{rails_env}"
  end

  desc "generate cache manifest file"
  task :create_manifest do
    run "cd #{release_path}; bundle exec rake manifest:create RAILS_ENV=#{rails_env}"
  end
end
