class AddStatusToImportInfo < ActiveRecord::Migration
  def change
    add_column :import_infos, :status, :string
  end
end
