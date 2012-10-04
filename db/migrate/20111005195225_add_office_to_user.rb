# -*- encoding : utf-8 -*-
class AddOfficeToUser < ActiveRecord::Migration
  def change
    add_column :users, :office_id, :integer
  end
end

