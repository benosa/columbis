class SetManagmentProfitFields < ActiveRecord::Migration
  def up
    Claim.find_each(:batch_size => 500) do |claim|
      profit, profit_in_percent = claim.send(:calculate_profit)
      # claim.update_column(:profit, claim.profit)
      # claim.update_column(:profit_in_percent, claim.profit_in_percent)
      Claim.where(:id => claim.id).update_all(:profit => profit, :profit_in_percent => profit_in_percent)
    end
  end

  def down
    Claim.update_all(:profit => 0, :profit_in_percent => 0)
  end
end
