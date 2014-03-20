class UnsetShortClaimListByDefault < ActiveRecord::Migration
  def change
    change_column :companies, :short_claim_list, :boolean, :default => false, :null => false
  end
end
