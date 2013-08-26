class AddNumToClaims < ActiveRecord::Migration
  def change
  	add_column :claims, :num, :integer
  end
end
