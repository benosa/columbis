namespace :company do
  desc "Company notifications"
  task :tariff_end => :environment do
    Company.just_soon_become_inactive.now_active.mail_tariff_end_soon_and_update_free
    Company.just_become_inactive.mail_tariff_end
  end
end