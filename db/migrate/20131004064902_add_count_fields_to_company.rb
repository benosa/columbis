class AddCountFieldsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :offices_count, :integer
    add_column :companies, :users_count, :integer
    add_column :companies, :claims_count, :integer
    add_column :companies, :tourists_count, :integer
    add_column :companies, :tasks_count, :integer
  end
end
