class AddClaimListV2ToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :claim_list_v2, :boolean, :default => true, :null => false
  	Company.update_all(:claim_list_v2 => false)
  end
end
