# -*- encoding : utf-8 -*-
class AddDocsReadyToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :docs_ready, :boolean, :default => false
  end
end
