class AddActiveToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :active, :boolean, :default => true, :null => false
  end
end
