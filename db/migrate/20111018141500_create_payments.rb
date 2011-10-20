class CreatePayments< ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :claim_id
      t.datetime :date_in, :null => false
      t.integer :payer_id, :null => false
      t.string :payer_type, :null => false
      t.integer :recipient_id, :null => false
      t.string :recipient_type, :null => false
      t.string :currency, :null => false
      t.float :amount, :default => 0.0
      t.string :description
      t.timestamps
    end
  end
end
