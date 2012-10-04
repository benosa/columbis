# -*- encoding : utf-8 -*-
class AddCountsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :insurance_count, :integer
    add_column :claims, :additional_insurance_count, :integer
    add_column :claims, :fuel_tax_count, :integer
  end
end
