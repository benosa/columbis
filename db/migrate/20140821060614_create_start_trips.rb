class CreateStartTrips < ActiveRecord::Migration
  def change
    create_table :start_trips do |t|
      t.integer :user_id
      t.integer :step

      t.timestamps
    end
  end
end
