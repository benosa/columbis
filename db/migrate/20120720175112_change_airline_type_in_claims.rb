# -*- encoding : utf-8 -*-
class ChangeAirlineTypeInClaims < ActiveRecord::Migration
  def up
  	change_column :claims, :airline, :string
  end

  def down
  	change_column :claims, :airline, :integer
  end
end
