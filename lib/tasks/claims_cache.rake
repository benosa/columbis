namespace :claims do
  desc "Expire cache for active claims"
  task :expire_active_cache => :environment do
    ClaimSweeper.expire_active_claims
  end
end