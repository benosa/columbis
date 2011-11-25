class AddOperatorPriceCurrencyToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :operator_price_currency, :string
  end
end
