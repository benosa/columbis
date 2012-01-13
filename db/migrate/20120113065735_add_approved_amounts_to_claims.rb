class AddApprovedAmountsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :approved_operator_advance, :float, :null => false, :default => 0.0
    add_column :claims, :approved_tourist_advance, :float, :null => false, :default => 0.0
  end
end
