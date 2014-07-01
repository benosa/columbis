class AddExtendedPotentialClientsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :extended_potential_clients, :boolean, :default => false, :null => false
  end
end
