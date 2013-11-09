class AddDeltaToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :delta, :boolean, :default => true, :null => false
  end
end
