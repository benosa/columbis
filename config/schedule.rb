set :output, File.expand_path('../../log/cron.log', __FILE__)
set :rvm_ruby_string, '2.0.0@tourism'

job_type :rake_with_rvm, 'rvm use :rvm_ruby_string && cd :path && RAILS_ENV=:environment bundle exec rake :task --trace :output'

every 1.day, :at => '1:17 am', :roles => [:app] do
  rake_with_rvm 'claims:expire_active_cache'
end

every 1.day, :at => '2:12 am', :roles => [:app] do
  rake_with_rvm 'dj:fetch_curses'
end

every 1.day, :at => '2:30 am', :roles => [:app] do
  rake_with_rvm 'demo:seed[index]'
end
