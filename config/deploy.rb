# -*- encoding : utf-8 -*-
require 'capistrano_colors'
require 'rvm/capistrano'
require 'bundler/capistrano'
require 'thinking_sphinx/deploy/capistrano'
require "delayed/recipes"

set :whenever_command, 'bundle exec whenever'
set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}_#{stage}" }
set :whenever_roles, [:db, :app]
require 'whenever/capistrano'

require 'capistrano/ext/multistage'
set :stages, %w(production staging dev)
set :default_stage, "dev"

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

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
after "deploy:update_code", "deploy:precompile_assets"
after "deploy:update_code", "deploy:create_manifest"
after "deploy:update_code", "deploy:claims:expire_active_cache"

after 'deploy:restart', 'unicorn:restart'  # app preloaded
after "deploy:restart", "deploy:cleanup"

namespace :deploy do

  task :config do
    run "cd #{release_path}/config && ln -sf #{shared_path}/config/database.yml database.yml"
    run "cd #{release_path}/config && ln -sf #{shared_path}/config/sphinx.yml sphinx.yml"
    run "cd #{release_path}/config && ln -sf #{shared_path}/config/mailer.yml mailer.yml"
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

  desc "precompile assets"
  task :precompile_assets, :roles => :app do
    # from = source.next_revision(current_revision)
    # if capture("cd #{release_path} && #{source.local.log(from)} vendor/assets/ app/assets/ lib/assets | wc -l").to_i > 0
    #   run "cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
    # else
    #   logger.info "Skipping asset pre-compilation because there were no asset changes"
    # end
    run "cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env}"
  end

  namespace :claims do
    desc 'expire view cache of active claims'
    task :expire_active_cache, :roles => :app do
      run "cd #{release_path} && bundle exec rake claims:expire_active_cache RAILS_ENV=#{rails_env}"
    end

    desc 'expire view cache of all claims'
    task :expire_all_cache, :roles => :app do
      run "cd #{release_path} && bundle exec rake claims:expire_all_cache RAILS_ENV=#{rails_env}"
    end
  end
end

namespace :update do
  desc "Copy remote production shared files to localhost"
  task :shared do
    run_locally "rsync --recursive --times --rsh=ssh --compress --human-readable --progress #{user}@#{domain}:#{shared_path}/uploads public"
  end

  desc "Dump remote production postgresql database, rsync to localhost"
  task :postgresql do
    get("#{current_path}/config/database.yml", "tmp/database.yml")

    remote_settings = YAML::load_file("tmp/database.yml")[rails_env]
    local_settings  = YAML::load_file("config/database.yml")["development"]
    dump_name = "#{remote_settings["database"]}.dump"
    dump_file = "#{shared_path}/#{dump_name}"

    def pg_def_options(settings)
      options = []
      options << "--username=#{settings["username"]}" if settings["username"]
      options << "--host=#{settings["host"]}" if settings["host"]
      options << "--port=#{settings["port"]}" if settings["port"]
      options.empty? ? '' : options.join(' ')
    end

    run "export PGPASSWORD=#{remote_settings["password"]} && pg_dump #{pg_def_options(remote_settings)} --file=#{dump_file} -Fc #{remote_settings["database"]}"

    run_locally "rsync --recursive --times --rsh=ssh --compress --human-readable --progress #{user}@#{domain}:#{dump_file} tmp/"

    run_locally "dropdb #{pg_def_options(local_settings)} #{local_settings["database"]}"
    run_locally "createdb #{pg_def_options(local_settings)} -T template0 #{local_settings["database"]}"
    run_locally "pg_restore #{pg_def_options(local_settings)} -d #{local_settings["database"]} tmp/#{dump_name}"
  end

  desc "Dump all remote data to localhost"
  task :all do
    update.shared
    update.postgresql
  end
end
