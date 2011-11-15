class AddOperatorPriceToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :operator_price, :float, :null => false, :default => 0.0
    add_column :claims, :operator_debt, :float, :null => false, :default => 0.0
    add_column :claims, :tourist_debt, :float, :null => false, :default => 0.0
  end
end
