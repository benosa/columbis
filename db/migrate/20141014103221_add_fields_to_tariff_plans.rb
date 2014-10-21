class AddFieldsToTariffPlans < ActiveRecord::Migration
  def change
    add_column :tariff_plans, :offices_count, :integer
    add_column :tariff_plans, :claims_count, :integer
  end
end
