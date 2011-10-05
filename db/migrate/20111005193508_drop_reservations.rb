class DropReservations < ActiveRecord::Migration
  def up
    drop_table :reservations
  end

  def down
    create_table :reservations do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end
  end
end

