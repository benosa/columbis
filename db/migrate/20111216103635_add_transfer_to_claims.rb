class AddTransferToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :transfer, :string
    add_column :claims, :relocation, :string
    add_column :claims, :service_class, :string
    add_column :claims, :additional_services, :string
  end
end
