class AddMemoTasksDoneToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :memo_tasks_done, :boolean, :default => false
  end
end
