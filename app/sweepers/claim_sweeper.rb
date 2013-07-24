class ClaimSweeper < ActionController::Caching::Sweeper
  observe Claim

  def expire_cache(fragment_key)
     # Set @controller variable if it's not exist, ex. wher it's called in rake task
    @controller ||= ActionController::Base.new
    expire_fragment(fragment_key)
  end

  # expire all claim list fragments
  def expire_claims
    expire_cache(/claim_list\/[-\d]+/)
  end

  # expire claim views
  def expire_claim(claim)
    expire_cache(/claim_list\/#{claim.cache_key}/)
  end

  def sweep(claim)
    expire_claims
    expire_claim(claim)
  end
  alias_method :after_update, :sweep
  alias_method :after_create, :sweep
  alias_method :after_destroy, :sweep

  # Class methods for rake tasks
  def self.sweeper
    @sweeper ||= send(:new)
  end

  def self.expire_active_claims
    sweeper.expire_claims
    Claim.where(:active => true).select([:id, :updated_at]).find_each do |claim| # for this project it could expire cache for all active claims
      sweeper.expire_claim(claim)
    end
  end

  def self.expire_all_claims
    sweeper.expire_claims
    Claim.select([:id, :updated_at]).find_each do |claim| # for this project it could expire cache for all active claims
      sweeper.expire_claim(claim)
    end
  end
end