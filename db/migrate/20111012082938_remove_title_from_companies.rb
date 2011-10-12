class RemoveTitleFromCompanies < ActiveRecord::Migration
  def up
    remove_column :companies, :title
  end

  def down
    add_column :companies, :title, :string
  end
end
