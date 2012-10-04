# -*- encoding : utf-8 -*-
class AddCanceledToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :canceled, :boolean, :default => false
  end
end
