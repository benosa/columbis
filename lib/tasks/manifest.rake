namespace :manifest do  
  desc "Create manifest"  
  task :create => :environment do
    DashboardController.new.create_manifest
  end
end