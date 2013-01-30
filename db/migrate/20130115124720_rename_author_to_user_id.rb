# -*- encoding : utf-8 -*-
class RenameAuthorToUserId < ActiveRecord::Migration
  def change
    rename_column :tasks, :author, :user_id
  end
end
