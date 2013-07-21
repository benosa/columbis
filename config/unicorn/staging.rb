# ------------------------------------------------------------------------------
# Sample rails 3 config
# ------------------------------------------------------------------------------

# Set your full path to application.
app_path = "/opt/apps/columbis-staging/current"
shared_path = "/opt/apps/columbis-staging/shared"

# Set unicorn options
worker_processes 2
preload_app true
timeout 30
listen "#{shared_path}/sockets/unicorn.sock", :backlog => 2048

# Spawn unicorn master worker for user apps (group: apps)
user 'deploy', 'deploy'

# Fill path to your app
working_directory app_path

# Should be 'production' by default, otherwise use other env
rails_env = ENV['RAILS_ENV'] || 'staging'

# Log everything to one file
stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"

# Set master PID location
pid "#{app_path}/tmp/pids/unicorn.pid"

# For memory saving with ruby 2.0
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
