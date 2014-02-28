class AddDataToImportInfo < ActiveRecord::Migration
  def change
    add_column :import_infos, :data, :text
  end
end
