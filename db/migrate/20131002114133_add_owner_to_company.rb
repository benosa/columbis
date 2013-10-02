class AddOwnerToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :owner, :integer
  end
end
