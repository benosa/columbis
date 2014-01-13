class AddImportToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :import, :string
  end
end
