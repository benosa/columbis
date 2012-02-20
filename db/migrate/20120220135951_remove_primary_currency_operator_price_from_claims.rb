class RemovePrimaryCurrencyOperatorPriceFromClaims < ActiveRecord::Migration
  def up
    remove_column :claims, :primary_currency_operator_price
  end

  def down
    add_column :claims, :primary_currency_operator_price, :float
  end
end
