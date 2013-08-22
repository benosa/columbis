class AddNotesToTourists < ActiveRecord::Migration
  def change
    add_column :tourists, :note, :text
  end
end
