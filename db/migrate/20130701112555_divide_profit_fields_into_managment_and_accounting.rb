class DivideProfitFieldsIntoManagmentAndAccounting < ActiveRecord::Migration
  def up
    rename_column :claims, :profit, :profit_acc
    rename_column :claims, :profit_in_percent, :profit_in_percent_acc
    add_column :claims, :profit, :float, :default => 0.0, :null => false
    add_column :claims, :profit_in_percent, :float, :default => 0.0, :null => false
  end

  def down
    remove_columns :claims, :profit, :profit_in_percent
    rename_column :claims, :profit_acc, :profit
    rename_column :claims, :profit_in_percent_acc, :profit_in_percent
  end
end
