class CreateItemFields < ActiveRecord::Migration
  def change
    create_table :item_fields do |t|
      t.integer :catalog_id
      t.string :name

      t.timestamps
    end
  end
end
