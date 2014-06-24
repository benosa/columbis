namespace :company do
  desc "Company notifications"
  task :tariff_end => :environment do
    Company.just_soon_become_inactive.mail_tariff_end_soon
  end
end