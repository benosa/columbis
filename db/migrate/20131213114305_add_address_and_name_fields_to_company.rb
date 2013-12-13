class AddAddressAndNameFieldsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :full_name, :string
    add_column :companies, :actual_address, :string
  end
end
