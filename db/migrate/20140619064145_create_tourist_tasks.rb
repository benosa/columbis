class CreateTouristTasks < ActiveRecord::Migration
  def change
    create_table :tourist_tasks do |t|
      t.string :name
      t.string :state
      t.integer :tourist_id
      t.integer :user_id

      t.timestamps
    end
  end
end
