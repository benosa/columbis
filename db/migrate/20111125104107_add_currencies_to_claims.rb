# -*- encoding : utf-8 -*-
class AddCurrenciesToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :visa_price_currency, :string, :null => false, :default => 'eur'
    add_column :claims, :insurance_price_currency, :string, :null => false, :default => 'eur'
    add_column :claims, :additional_insurance_price_currency, :string, :null => false, :default => 'eur'
    add_column :claims, :fuel_tax_price_currency, :string, :null => false, :default => 'eur'
  end
end
