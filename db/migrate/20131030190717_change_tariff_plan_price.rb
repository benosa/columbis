class ChangeTariffPlanPrice < ActiveRecord::Migration
  def up
    change_column :tariff_plans, :price, :float
  end

  def down
    change_column :tariff_plans, :price, :integer
  end
end
