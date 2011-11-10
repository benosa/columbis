class RemoveTimesFromClaim < ActiveRecord::Migration
  def self.up
    remove_column :claims, :time_to
    remove_column :claims, :time_back
  end

  def self.down
    add_column :claims, :time_to, :time
    add_column :claims, :time_back, :time
  end
end
