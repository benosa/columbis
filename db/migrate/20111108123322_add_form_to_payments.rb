# -*- encoding : utf-8 -*-
class AddFormToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :form, :string, :null => false
  end
end
