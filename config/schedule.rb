set :output, File.expand_path('../../log/cron.log', __FILE__)

every 1.day, :at => '1:17am', :roles => [:app] do
  rake 'claims:expire_active_cache'
end

every '25 5-17/2,23 * * *' do
  command File.expand_path('../../script/transfer', __FILE__)
end