class SetActiveInClaims < ActiveRecord::Migration
  def up
    Claim.find_each(:batch_size => 500) do |claim|
      claim.update_column(:active, claim.is_active?)
    end
  end

  def down
    Claim.update_all(:active => true)
  end
end
