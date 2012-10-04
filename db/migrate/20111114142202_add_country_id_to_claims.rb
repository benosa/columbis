# -*- encoding : utf-8 -*-
class AddCountryIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :country_id, :integer
  end
end
