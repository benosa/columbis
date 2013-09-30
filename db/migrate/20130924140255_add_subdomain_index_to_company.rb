class AddSubdomainIndexToCompany < ActiveRecord::Migration
  def change
    add_index :companies, :subdomain
  end
end
