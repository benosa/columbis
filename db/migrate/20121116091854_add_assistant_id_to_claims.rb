# -*- encoding : utf-8 -*-
class AddAssistantIdToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :assistant_id, :integer
  end
end
