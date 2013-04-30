set :output, File.expand_path('../../log/cron.log', __FILE__)
set :rvm_ruby_string, '1.9.3@tourism'

job_type :rake_with_rvm, 'rvm use :rvm_ruby_string && cd :path && RAILS_ENV=:environment bundle exec rake :task --trace :output'

every 1.day, :at => '1:17am', :roles => [:app] do
  rake_with_rvm 'claims:expire_active_cache'
end

every '25 5-17/2,23 * * *' do
  command File.expand_path('../../script/transfer', __FILE__)
end