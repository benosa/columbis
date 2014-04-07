# Custom delayed jobs for operators
module TouristJobs

  # Touch all claims with specific operator_id
  def self.touch_claims(tourist_id)
    Delayed::Job.enqueue TouchClaims.new(tourist_id)
  end

  class TouchClaims < Struct.new(:tourist_id)
    def perform
      tourist_claim = TouristClaim.arel_table
      Claim.joins(:tourist_claim).where(tourist_claim[:tourist_id].eq(tourist_id)).update_all(updated_at: Time.now.utc)
    end
  end
end