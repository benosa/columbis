class AddDiscountToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :discount, :decimal, :default => 0.0, :null => false
  end
end
