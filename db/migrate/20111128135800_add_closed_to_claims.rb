class AddClosedToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :closed, :boolean, :default => false
  end
end
