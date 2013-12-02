class AddContractNameToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :contract_name, :string
  end
end
