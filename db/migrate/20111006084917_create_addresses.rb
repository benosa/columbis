class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :addressable_id
      t.string :addressable_type
      t.string :region
      t.integer :zip_code
      t.string :house_number
      t.string :housing
      t.string :office_number
      t.string :street
      t.string :phone_number

      t.timestamps
    end
  end
end
