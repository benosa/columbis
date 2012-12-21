class AddBonusToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :bonus, :decimal, :precision => 15, :scale => 2, :default => 0.0, :null => false
    add_column :claims, :bonus_percent, :decimal, :precision => 5, :scale => 2, :default => 0.0, :null => false
  end
end
