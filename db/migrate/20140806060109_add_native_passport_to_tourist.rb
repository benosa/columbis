class AddNativePassportToTourist < ActiveRecord::Migration
  def change
    add_column :tourists, :native_passport, :string
  end
end
