class AddExcludedFromProfitToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :excluded_from_profit, :boolean, :default => false, :null => false
  end
end
