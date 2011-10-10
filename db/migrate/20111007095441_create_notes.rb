class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :item_id
      t.integer :item_field_id
      t.string :value
      t.timestamps
    end
  end
end
