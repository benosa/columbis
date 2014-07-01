class AddExtendedPotentialClientsToTariff < ActiveRecord::Migration
  def change
    add_column :tariff_plans, :extended_potential_clients, :boolean, :default => false, :null => false
  end
end
