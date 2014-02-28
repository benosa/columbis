class CreateImportItems < ActiveRecord::Migration
  def change
    create_table :import_items do |t|
      t.integer :import_info_id
      t.string :model_class
      t.integer :model_id
      t.text :data
      t.integer :file_line

      t.timestamps
    end
  end
end
