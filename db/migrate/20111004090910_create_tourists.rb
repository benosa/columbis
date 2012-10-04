# -*- encoding : utf-8 -*-
class CreateTourists < ActiveRecord::Migration
  def change
    create_table :tourists do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.integer :passport_series
      t.integer :passport_number
      t.date :date_of_birth
      t.date :passport_valid_until
      t.string :phone_number
      t.string :address

      t.timestamps
    end
  end
end
