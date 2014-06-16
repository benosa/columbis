class CreateTouristComments < ActiveRecord::Migration
  def change
    create_table :tourist_comments do |t|
      t.integer :user_id
      t.integer :tourist_id
      t.text :body

      t.timestamps
    end
  end
end
