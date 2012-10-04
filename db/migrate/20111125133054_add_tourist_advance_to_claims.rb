# -*- encoding : utf-8 -*-
class AddTouristAdvanceToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :tourist_advance, :float, :null => false, :default => 0.0
    add_column :claims, :tourist_paid, :string
  end
end
