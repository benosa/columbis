class ChangeExtendedPotentialClientsInCompany < ActiveRecord::Migration
  def up
    change_column :companies, :extended_potential_clients, :boolean, :default => true, :null => false
  end
end
