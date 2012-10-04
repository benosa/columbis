# -*- encoding : utf-8 -*-
class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.integer :passport_series
      t.integer :passport_number
      t.string :phone_number
      t.string :address
      t.date :passport_valid_until
      t.date :date_of_birth

      t.timestamps
    end
  end
end
