namespace :claims do
  desc "Expire cache for active claims"
  task :expire_active_cache => :environment do
    ClaimSweeper.expire_active_claims
  end

  desc "Expire cache for all claims"
  task :expire_all_cache => :environment do
    ClaimSweeper.expire_all_claims
  end
end