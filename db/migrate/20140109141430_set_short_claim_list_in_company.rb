class SetShortClaimListInCompany < ActiveRecord::Migration
  def up
    Company.update_all(:short_claim_list => false)
  end
end
