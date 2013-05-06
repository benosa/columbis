set :output, { :standart => 'log/cron.log', :error => 'log/cron.log' }

every 1.day, :at => '1:17 am', :roles => [:app] do
  rake 'claims:expire_active_cache'
end

every 1.day, :at => '2:12 am', :roles => [:app] do
  rake 'dj:fetch_curses'
end
