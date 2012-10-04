# -*- encoding : utf-8 -*-
class RemoveTouristIdFromClaims < ActiveRecord::Migration
  def change
    remove_column :claims, :tourist_id
  end
end
