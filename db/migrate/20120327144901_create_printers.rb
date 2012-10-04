# -*- encoding : utf-8 -*-
class CreatePrinters < ActiveRecord::Migration
  def self.up
    create_table :printers do |t|
      t.belongs_to :company
      t.belongs_to :country
      t.string :template
      t.string :mode
    end
  end

  def self.down
    drop_table :printers
  end
end
