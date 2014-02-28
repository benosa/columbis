class AddSuccessToImportItem < ActiveRecord::Migration
  def change
  	add_column :import_items, :success, :boolean
  end
end
