# -*- encoding : utf-8 -*-
class CreateDropdownValues < ActiveRecord::Migration
  def self.up
    create_table :dropdown_values do |t|
      t.string :list
      t.string :value
    end
    add_index :dropdown_values, :list
    add_index :dropdown_values, :value
  end

  def self.down
    drop_table :dropdown_values
  end
end
