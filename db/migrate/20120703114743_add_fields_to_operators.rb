class AddFieldsToOperators < ActiveRecord::Migration
  def change
    add_column :operators, :register_number, :string
    add_column :operators, :register_series, :string
    add_column :operators, :inn, :string
    add_column :operators, :ogrn, :string
    add_column :operators, :site, :string
    add_column :operators, :insurer, :string
    add_column :operators, :insurer_address, :string
    add_column :operators, :insurer_contract, :string
    add_column :operators, :insurer_contract_date, :date
    add_column :operators, :insurer_contract_start, :date
    add_column :operators, :insurer_contract_end, :date
    add_column :operators, :insurer_provision, :string
  end
end
