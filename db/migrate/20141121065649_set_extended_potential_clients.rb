class SetExtendedPotentialClients < ActiveRecord::Migration
  def up
  	Company.update_all(:extended_potential_clients => true)
  end
end
