class CopyIdToNumClaims < ActiveRecord::Migration
  class Claim < ActiveRecord::Base; end

  def up
  	Claim.find_each(:batch_size => 500) do |claim|
      claim.update_column(:num, claim.id)
    end
  end

  def down
  	Claim.update_all(:num => 0)
  end
end
