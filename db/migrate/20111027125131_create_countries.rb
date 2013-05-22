# -*- encoding : utf-8 -*-
class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name
      t.datetime :created_at, :null => true
      t.datetime :updated_at, :null => true
    end
  end

  def self.down
    drop_table :countries
  end
end
