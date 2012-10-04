# -*- encoding : utf-8 -*-
class CreateAirlines < ActiveRecord::Migration
  def self.up
    create_table :airlines do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :airlines
  end
end
