class RenameGroupInTourists < ActiveRecord::Migration
  def up
  	rename_column :tourists, :group, :class_group
  end

  def down
  end
end
