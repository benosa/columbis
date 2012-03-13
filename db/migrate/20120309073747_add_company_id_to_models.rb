class AddCompanyIdToModels < ActiveRecord::Migration
  def change
    add_column :addresses, :company_id, :integer
    add_column :airlines, :company_id, :integer
    add_column :catalogs, :company_id, :integer
    add_column :cities, :company_id, :integer
    add_column :claims, :company_id, :integer
    add_column :clients, :company_id, :integer
    add_column :countries, :company_id, :integer
    add_column :currency_courses, :company_id, :integer
    add_column :dropdown_values, :company_id, :integer
    add_column :item_fields, :company_id, :integer
    add_column :items, :company_id, :integer
    add_column :notes, :company_id, :integer
    add_column :offices, :company_id, :integer
    add_column :operators, :company_id, :integer
    add_column :payments, :company_id, :integer
    add_column :tourists, :company_id, :integer
  end
end
