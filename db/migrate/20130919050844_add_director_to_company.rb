class AddDirectorToCompany < ActiveRecord::Migration
  def up
    add_column :companies, :director, :string
    add_column :companies, :director_genitive, :string
    remove_column :companies, :oficial_letter_signature
  end

  def down
    remove_column :companies, :director, :string
    remove_column :companies, :director_genitive, :string
    add_column :companies, :oficial_letter_signature
  end
end