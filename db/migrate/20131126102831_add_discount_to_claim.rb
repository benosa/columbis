class AddDiscountToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :discount, :decimal
  end
end
