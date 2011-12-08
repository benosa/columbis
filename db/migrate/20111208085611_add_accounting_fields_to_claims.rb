class AddAccountingFieldsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :primary_currency_operator_price, :float, :null => false, :default => 0.0
    add_column :claims, :profit, :float, :null => false, :default => 0.0
    add_column :claims, :profit_in_percent, :float, :null => false, :default => 0.0
  end
end
