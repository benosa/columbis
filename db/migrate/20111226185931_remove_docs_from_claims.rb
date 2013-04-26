# -*- encoding : utf-8 -*-
class RemoveDocsFromClaims < ActiveRecord::Migration
  def up
    remove_column :claims, :docs_memo
    remove_column :claims, :docs_ticket
  end

  def down
    add_column :claims, :docs_memo, :string
    add_column :claims, :docs_ticket, :string
  end
end
