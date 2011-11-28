class AddDeltaToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :delta, :boolean, :default => true
  end
end
