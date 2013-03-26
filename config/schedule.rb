set :output, { :standart => 'log/cron.log', :error => 'log/cron.log' }

every 1.day, :at => '1:17am', :roles => [:app] do
  rake 'claims:expire_active_cache'
end