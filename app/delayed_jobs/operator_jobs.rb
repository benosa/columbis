# Custom delayed jobs for operators
module OperatorJobs

	# Touch all claims with specific operator_id
	def self.touch_claims(operator_id)
		Delayed::Job.enqueue TouchClaims.new(operator_id)
	end

	class TouchClaims < Struct.new(:operator_id)
	  def perform
	    Claim.where(operator_id: operator_id).update_all(updated_at: Time.now.utc)
	  end
	end
end