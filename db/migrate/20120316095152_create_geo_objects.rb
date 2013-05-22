# -*- encoding : utf-8 -*-
class CreateGeoObjects < ActiveRecord::Migration
  class Country < ActiveRecord::Base; end

  def self.up
    create_table :regions do |t|
      t.integer :country_id
      t.string :name
    end

    add_column :cities, :region_id, :integer

    plain_sql = File.open(Rails.root.join("db/geo_utf.sql")).read
    execute(plain_sql)

    add_index :countries, [:name]
    add_index :regions, [:country_id, :name]
    add_index :regions, [:name]
    add_index :cities, [:country_id, :region_id, :name]
    add_index :cities, [:name]

    Country.find_each(:batch_size => 500){ |c| c.save! }
  end

  def self.down
    remove_index :countries, :column => [:name]
    remove_index :cities, :column => [:country_id, :region_id, :name]
    remove_index :cities, :column => [:name]

    remove_column :cities, :region_id
    drop_table :regions
  end
end
