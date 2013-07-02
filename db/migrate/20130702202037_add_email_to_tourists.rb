class AddEmailToTourists < ActiveRecord::Migration
  def change
    add_column :tourists, :email, :string
  end
end
