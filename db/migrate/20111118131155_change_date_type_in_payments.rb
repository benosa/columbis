# -*- encoding : utf-8 -*-
class ChangeDateTypeInPayments < ActiveRecord::Migration
  def self.up
    change_column :payments, :date_in, :date
  end

  def self.down
    change_column :payments, :date_in, :datetime
  end
end
