class CreateFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.string :airline
      t.string :airport_from
      t.string :airport_to
      t.string :flight_number
      t.datetime :depart
      t.datetime :arrive
      t.integer :claim_id

      t.timestamps
    end
  end
end
