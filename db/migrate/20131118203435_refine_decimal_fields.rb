class RefineDecimalFields < ActiveRecord::Migration
  def up
    change_column :tariff_plans, :price,   :decimal, :precision => 15, :scale => 2, :default => 0.0, :null => false
    change_column :user_payments, :amount, :decimal, :precision => 15, :scale => 2, :default => 0.0, :null => false
    change_column :companies, :paid,       :decimal, :precision => 15, :scale => 2, :default => 0.0, :null => false
  end

  def down
    change_column :tariff_plans, :price, :decimal, :default => 0.0, :null => false
    change_column :user_payments, :amount, :decimal
    change_column :companies, :paid, :decimal
  end
end
