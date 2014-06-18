class DeleteTouristActions < ActiveRecord::Migration
  def up
  	remove_column :tourists, :actions
  end

  def down
  end
end
