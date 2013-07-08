class AddDeltaToCountry < ActiveRecord::Migration
  def change
  	add_column :countries, :delta, :boolean, :default => true, :null => false
  end
end
