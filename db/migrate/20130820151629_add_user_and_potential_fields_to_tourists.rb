class AddUserAndPotentialFieldsToTourists < ActiveRecord::Migration
  def change
  	add_column :tourists, :user_id, :integer
  	add_column :tourists, :wishes, :text
  	add_column :tourists, :actions, :text
  end
end
