class AddAdditionalServicesPriceToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :additional_services_price, :float, :default => 0.0, :null => false
    add_column :claims, :additional_services_price_currency, :string, :default => "eur", :null => false
  end
end
