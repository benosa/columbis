# -*- encoding : utf-8 -*-
class AddApprovedToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :approved, :boolean, :default => false
    add_index :payments, :approved
  end
end
