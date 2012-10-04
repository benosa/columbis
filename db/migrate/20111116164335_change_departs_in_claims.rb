# -*- encoding : utf-8 -*-
class ChangeDepartsInClaims < ActiveRecord::Migration
  def self.up
    remove_column :claims, :depart_to
    remove_column :claims, :depart_back
    add_column :claims, :depart_to, :datetime
    add_column :claims, :depart_back, :datetime
  end

  def self.down
    remove_column :claims, :depart_to
    remove_column :claims, :depart_back
    add_column :claims, :depart_to, :string
    add_column :claims, :depart_back, :string
  end
end
