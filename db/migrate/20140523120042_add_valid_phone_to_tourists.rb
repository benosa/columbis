class AddValidPhoneToTourists < ActiveRecord::Migration
  def change
    add_column :tourists, :phone_number_valid, :string
  end
end
