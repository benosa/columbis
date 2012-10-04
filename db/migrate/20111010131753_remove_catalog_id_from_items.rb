# -*- encoding : utf-8 -*-
class RemoveCatalogIdFromItems < ActiveRecord::Migration
  def up
    remove_column :items, :catalog_id
  end

  def down
    add_column :items, :catalog_id, :string
  end
end
