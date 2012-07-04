class AddInnToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :inn, :string
  end
end
