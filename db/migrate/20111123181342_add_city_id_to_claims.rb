# -*- encoding : utf-8 -*-
class AddCityIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :city_id, :integer
  end
end
