# -*- encoding : utf-8 -*-
class RemoveMemoFromCountry < ActiveRecord::Migration
  def up
    remove_column :countries, :memo
    remove_column :countries, :company_id
  end

  def down
    add_column :countries, :memo, :string
    add_column :countries, :company_id, :integer
  end
end
