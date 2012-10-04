# -*- encoding : utf-8 -*-
class AddTouristStatToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :tourist_stat, :string
  end
end
