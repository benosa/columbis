# -*- encoding : utf-8 -*-
class AddCommentToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :comment, :text
  end
end
