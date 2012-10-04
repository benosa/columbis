# -*- encoding : utf-8 -*-
class AddPriceFieldsToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :tour_price, :float, :default => 0.0
    add_column :claims, :visa_price, :float, :default => 0.0
    add_column :claims, :insurance_price, :float, :default => 0.0
    add_column :claims, :additional_insurance_price, :float, :default => 0.0
    add_column :claims, :fuel_tax_price,:float, :default => 0.0
    add_column :claims, :total_tour_price, :float, :default => 0.0
    add_column :claims, :primary_currency_price, :float, :default => 0.0

    add_column :claims, :course, :float, :default => 0.0
    add_column :claims, :currency, :string, :null => false
  end
end
