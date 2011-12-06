class AddOperatorAdvanceToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :operator_advance, :float, :null => false, :default => 0.0
    add_column :claims, :operator_paid, :string
  end
end
