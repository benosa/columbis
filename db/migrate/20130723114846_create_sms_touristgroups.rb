class CreateSmsTouristgroups < ActiveRecord::Migration
  def change
    create_table :sms_touristgroups do |t|
      t.integer :tourist_id
      t.integer :sms_group_id
      t.integer :position

      t.timestamps
    end
  end
end
