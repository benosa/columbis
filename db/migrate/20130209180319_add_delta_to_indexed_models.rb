class AddDeltaToIndexedModels < ActiveRecord::Migration
  def change
    add_column :addresses, :delta, :boolean, default: true
    add_column :dropdown_values, :delta, :boolean, default: true
    add_column :operators, :delta, :boolean, default: true
    add_column :tasks, :delta, :boolean, default: true
    add_column :tourists, :delta, :boolean, default: true
    add_column :users, :delta, :boolean, default: true
  end
end
