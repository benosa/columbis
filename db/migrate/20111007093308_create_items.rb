class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :catalog_id

      t.timestamps
    end
  end
end
