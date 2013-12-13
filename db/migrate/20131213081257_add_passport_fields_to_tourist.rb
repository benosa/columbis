class AddPassportFieldsToTourist < ActiveRecord::Migration
  def change
    add_column :tourists, :fio_latin, :string
    add_column :tourists, :passport_issued, :string
  end
end
