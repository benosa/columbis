class RenameExecuterToExecuterId < ActiveRecord::Migration
  def change
    rename_column :tasks, :executer, :executer_id
  end
end
