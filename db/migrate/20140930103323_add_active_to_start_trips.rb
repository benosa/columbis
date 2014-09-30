class AddActiveToStartTrips < ActiveRecord::Migration
  def change
    add_column :start_trips, :active, :boolean, :default => true
  end
end
