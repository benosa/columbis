# -*- encoding : utf-8 -*-
class RemoveTimestampsFromGeo < ActiveRecord::Migration
  def up
    [:cities, :countries].each do |tab|
      remove_column tab, :created_at
      remove_column tab, :updated_at
    end
  end

  def down
    [:cities, :countries].each do |tab|
      add_column tab, :created_at, :datetime
      add_column tab, :updated_at, :datetime
    end
  end
end
