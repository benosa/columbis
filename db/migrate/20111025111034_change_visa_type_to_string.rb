# -*- encoding : utf-8 -*-
class ChangeVisaTypeToString < ActiveRecord::Migration
  def up
    change_column :claims, :visa, :string, :null => false
    add_column :claims, :visa_check, :datetime
  end

  def down
    remove_column :claims, :visa_check
  end
end
