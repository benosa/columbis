class AddGroupToTourists < ActiveRecord::Migration
  def change
    add_column :tourists, :group, :string
  end
end
