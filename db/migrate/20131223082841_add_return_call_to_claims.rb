class AddReturnCallToClaims < ActiveRecord::Migration
  def change
  	add_column :claims, :return_call, :boolean, :default => false
  end
end
