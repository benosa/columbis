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
after "deploy:update_code", "deploy:migrate"
#after "deploy:migrate", "deploy:seed"
after  "deploy:update_code", "thinking_sphinx:configure"
after  "deploy:update_code", "thinking_sphinx:index"
after  "deploy:update_code", "thinking_sphinx:start"

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
end
