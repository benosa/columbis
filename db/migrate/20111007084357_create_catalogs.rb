# -*- encoding : utf-8 -*-
class CreateCatalogs < ActiveRecord::Migration
  def change
    create_table :catalogs do |t|
      t.string :name

      t.timestamps
    end
  end
end
