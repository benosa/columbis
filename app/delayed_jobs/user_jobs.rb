# Custom delayed jobs for operators
module UserJobs

  # Touch all claims with specific operator_id
  def self.touch_claims(user_id)
    Delayed::Job.enqueue TouchClaims.new(user_id)
  end

  class TouchClaims < Struct.new(:user_id)
    def perform
      claims = Claim.arel_table
      Claim.where(claims[:user_id].eq(user_id).or(claims[:assistant_id].eq(user_id))).update_all(updated_at: Time.now.utc)
    end
  end
end