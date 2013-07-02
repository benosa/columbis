class AddDeltaToCities < ActiveRecord::Migration
  def change
    add_column :cities, :delta, :boolean, :default => true, :null => false
  end
end
