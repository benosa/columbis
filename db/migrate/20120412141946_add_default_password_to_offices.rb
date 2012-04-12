class AddDefaultPasswordToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :default_password, :string
  end
end
