class AddCompanyIdToCountiesAndCities < ActiveRecord::Migration
  def up
    add_column :countries, :company_id, :integer
    add_column :countries, :common, :boolean, :default => false
    add_column :cities, :company_id, :integer
    add_column :cities, :common, :boolean, :default => false

    add_index :countries, :company_id
    add_index :countries, :common
    add_index :cities, :company_id
    add_index :cities, :common
  end

  def down
    remove_index :countries, :company_id
    remove_index :countries, :common
    remove_index :cities, :company_id
    remove_index :cities, :common

    remove_column :countries, :company_id
    remove_column :countries, :common
    remove_column :cities, :company_id
    remove_column :cities, :common
  end
end
