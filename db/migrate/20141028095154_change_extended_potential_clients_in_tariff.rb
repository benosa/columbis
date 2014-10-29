class ChangeExtendedPotentialClientsInTariff < ActiveRecord::Migration
  def up
    change_column :tariff_plans, :extended_potential_clients, :boolean, :default => true, :null => false
  end
end
