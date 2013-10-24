class AddDeltaToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :delta, :boolean, :default => true, :null => false
  end
end
