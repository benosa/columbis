class AddTourDurationToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :tour_duration, :integer
    Claim.where("(departure_date >= arrival_date) AND (departure_date IS NOT NULL) AND (arrival_date IS NOT NULL)")
      .update_all("\"tour_duration\" = \"departure_date\" - \"arrival_date\" + 1")
  end
end
