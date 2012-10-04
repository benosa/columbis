# -*- encoding : utf-8 -*-
class AddColorToUser < ActiveRecord::Migration
  def change
    add_column :users, :color, :string
  end
end
