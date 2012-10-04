# -*- encoding : utf-8 -*-
class AddAmountPrimToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :amount_prim, :float, :default => 0.0
  end
end
