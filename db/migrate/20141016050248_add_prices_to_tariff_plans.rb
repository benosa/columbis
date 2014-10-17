class AddPricesToTariffPlans < ActiveRecord::Migration
  def change
    add_column :tariff_plans, :price_half_year, :float, :default => 0.0
    add_column :tariff_plans, :price_year, :float, :default => 0.0
  end
end
