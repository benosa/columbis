# -*- encoding : utf-8 -*-
class CreateCityCompanies < ActiveRecord::Migration
  def self.up
    create_table :city_companies do |t|
      t.belongs_to :city
      t.belongs_to :company
    end
  end

  def self.down
    drop_table :city_companies
  end
end
