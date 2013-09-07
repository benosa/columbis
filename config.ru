# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if Rails.env.production? or Rails.env.staging?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == CONFIG[:delayed_job_user] && password == CONFIG[:delayed_job_password]
  end
end

run Tourism::Application
