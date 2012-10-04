# -*- encoding : utf-8 -*-
class AddCommonToDropdownValues < ActiveRecord::Migration
  def change
    add_column :dropdown_values, :common, :boolean, :default => false
  end
end
