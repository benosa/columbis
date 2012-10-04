# -*- encoding : utf-8 -*-
class RemoveTotalPriceFromClaims < ActiveRecord::Migration
  def self.up
    remove_column :claims, :total_tour_price
  end

  def self.down
    add_column :claims, :total_tour_price, :float
  end
end
