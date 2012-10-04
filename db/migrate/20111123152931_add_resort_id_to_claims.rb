# -*- encoding : utf-8 -*-
class AddResortIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :resort_id, :integer
  end
end
