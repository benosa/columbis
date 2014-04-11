# Custom delayed jobs for operators
module OperatorJobs

  # Touch all claims with specific operator_id
  def self.touch_claims(operator_id)
    Delayed::Job.enqueue TouchClaims.new(operator_id)
  end

  def self.update_operator(operator_id)
    Delayed::Job.enqueue ExportFile.new(company_id)
  end

  class UpdateCommonOperator < Struct.new(:operator_id)
    def self.working?(operator_id)
      !!Rails.cache.read("refresh_operator_#{operator_id}")
    end

    def perform
      %x(bundle exec rake peck:init[#{@agent.url},#{@agent.terms}])
    end

    def enqueue(job)
      Rails.cache.write "refresh_operator_#{operator_id}", true
    end

    def after(job)
      Rails.cache.clear "refresh_operator_#{operator_id}"
    end

  end

  class TouchClaims < Struct.new(:operator_id)
    def perform
      Claim.where(operator_id: operator_id).update_all(updated_at: Time.now.utc)
    end
  end
end