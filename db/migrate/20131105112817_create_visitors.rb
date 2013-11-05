class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors do |t|
      t.string :email, :null => false, :default => ""
      t.string :name
      t.string :phone
      t.integer :user_id
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.boolean :confirmed

      t.timestamps
    end
  end
end
