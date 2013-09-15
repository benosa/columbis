class AddUseOfficePasswordToUser < ActiveRecord::Migration
  def change
    add_column :users, :use_office_password, :boolean, :default => false
  end
end
