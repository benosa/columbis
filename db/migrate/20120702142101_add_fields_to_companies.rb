class AddFieldsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :okpo, :string
    add_column :companies, :site, :string
  end
end
