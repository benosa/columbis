namespace :db do
  desc "Migrate to specified database"
  task :migrate_to, [:database] => :environment do |t, args|
    db_conf = ActiveRecord::Base.configurations[Rails.env]
    db_conf['database'] = args[:database] if args[:database]
    ActiveRecord::Base.establish_connection db_conf
    Rake::Task['db:migrate'].invoke
    # ActiveRecord::Migrator.migrate("db/migrate")
  end
end