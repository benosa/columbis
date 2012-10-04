# -*- encoding : utf-8 -*-
class RemoveNumFromClaims < ActiveRecord::Migration
  def self.up
    remove_column :claims, :num
  end

  def self.down
    add_column :claims, :num, :integer
  end
end
