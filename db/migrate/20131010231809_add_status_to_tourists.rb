class AddStatusToTourists < ActiveRecord::Migration
  def change
    add_column :tourists, :state, :string
  end
end
