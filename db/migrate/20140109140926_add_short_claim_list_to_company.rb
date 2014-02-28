class AddShortClaimListToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :short_claim_list, :boolean, :default => true, :null => false
  end
end
