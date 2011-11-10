class RemoveDescriptionFromClaim < ActiveRecord::Migration
  def self.up
    remove_column :claims, :description
  end

  def self.down
    add_column :claims, :description, :text
  end
end
