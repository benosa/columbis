class CreateImportInfos < ActiveRecord::Migration
  def change
    create_table :import_infos do |t|
      t.integer :company_id
      t.string :num
      t.string :integer
      t.datetime :load_date
      t.string :filename
      t.integer :success_count
      t.integer :count

      t.timestamps
    end
  end
end
