class CreateUserPayments < ActiveRecord::Migration
  def change
    create_table :user_payments do |t|
      t.decimal :amount
      t.string :currency
      t.integer :invoice
      t.integer :period
      t.string :description
      t.boolean :approved, :default => false, :null => false
      t.integer :company_id
      t.integer :user_id
      t.integer :tariff_id
      t.boolean :delta, :default => true, :null => false

      t.timestamps
    end
  end
end
