# -*- encoding : utf-8 -*-
class RemoveCompanyFromCities < ActiveRecord::Migration
  def up
    remove_column :cities, :company_id
  end

  def down
    add_column :cities, :company_id, :integer
  end
end
