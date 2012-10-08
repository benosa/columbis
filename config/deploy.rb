# -*- encoding : utf-8 -*-
require 'capistrano_colors'
require 'rvm/capistrano'
require 'bundler/capistrano'
require 'thinking_sphinx/deploy/capistrano'

require 'capistrano/ext/multistage'
set :default_stage, "staging"

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :rvm_ruby_string, "ree@tourism"
set :rvm_type, :user

set :scm, :git
set :keep_releases, 5
set :repository,  "git@devmen.unfuddle.com:devmen/tourism.git"

set :user, "deploy"
set :use_sudo, false

before "deploy:update_code", "thinking_sphinx:stop"
after "deploy:update_code", "deploy:config"
after "deploy:update_code", "deploy:uploads"
after "deploy:update_code", "deploy:migrate"
#after "deploy:migrate", "deploy:seed"

#after "deploy:update_code", "deploy:repair_sequences"
after "deploy:update_code", "thinking_sphinx:configure"
after "deploy:update_code", "thinking_sphinx:index"
after "deploy:update_code", "thinking_sphinx:start"
# after 'deploy:finalize_update', 'deploy:symlink_sphinx_indexes'
after "thinking_sphinx:start", "deploy:create_manifest"
after "deploy:restart", "deploy:cleanup"

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

  desc "Link up Sphinx's indexes"
  task :symlink_sphinx_indexes, :roles => [:app] do
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx" # If current_path doesn't work for you, use release_path.
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path} && bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end

  desc "secuenses changes when need generate new value for relaten table"
  task :repair_sequences do
    run "cd #{current_path} && bundle exec rake repair:sequences RAILS_ENV=#{rails_env}"
  end

  desc "generate cache manifest file"
  task :create_manifest do
    run "cd #{release_path} && bundle exec rake manifest:create RAILS_ENV=#{rails_env}"
  end
end
