class AddCommonToOperators < ActiveRecord::Migration
  def change
    add_column :operators, :common, :boolean, :default => false
    add_index :operators, :company_id
    add_index :operators, :common
  end
end
