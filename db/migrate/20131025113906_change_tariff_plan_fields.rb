class ChangeTariffPlanFields < ActiveRecord::Migration
  def up
    change_column :tariff_plans, :price, :decimal
    add_column :tariff_plans, :default, :boolean, :default => false, :null => false
  end

  def down
    change_column :tariff_plans, :price, :integer
    remove_column :tariff_plans, :default
  end
end
