# -*- encoding : utf-8 -*-
class AddApprovedOperatorAdvancePrimToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :approved_operator_advance_prim, :float, :null => false, :default => 0.0
  end
end
