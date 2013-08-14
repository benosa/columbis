class ChangePassportColumnsInTourists < ActiveRecord::Migration
  def up
  	change_column :tourists, :passport_series, :string
  	change_column :tourists, :passport_number, :string
  end

  def down
  	change_column :tourists, :passport_series, :integer
  	change_column :tourists, :passport_number, :integer
  end
end
