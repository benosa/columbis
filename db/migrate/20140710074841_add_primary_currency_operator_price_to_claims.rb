class AddPrimaryCurrencyOperatorPriceToClaims < ActiveRecord::Migration
  def change
  	add_column :claims, :primary_currency_operator_price, :float, :default => 0.0, :null => false
  end
end
