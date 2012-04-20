class DropAirlines < ActiveRecord::Migration
  def up
    drop_table :airlines
    rename_column :claims, :airline_id, :airline
  end

  def down
    create_table :airlines do |t|
      t.string :name
      t.integer :company_id
      t.timestamps
    end
    rename_column :claims, :airline, :airline_id
  end
end
