class CreateTourists < ActiveRecord::Migration
  def change
    create_table :tourists do |t|
      t.string :firstname
      t.string :lastname
      t.string :middlename
      t.integer :pser
      t.integer :pnum
      t.date :dateofbirth
      t.date :pvalid
      t.string :phonenum
      t.string :address

      t.timestamps
    end
  end
end
