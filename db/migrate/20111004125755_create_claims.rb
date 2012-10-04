# -*- encoding : utf-8 -*-
class CreateClaims < ActiveRecord::Migration
  def self.up
    create_table :claims do |t|
      t.belongs_to :tourist
      t.belongs_to :user
      t.text :description
      t.datetime :check_date
      t.timestamps
    end
  end

  def self.down
    drop_table :claims
  end
end

