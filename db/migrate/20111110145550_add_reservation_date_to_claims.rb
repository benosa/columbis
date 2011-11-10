class AddReservationDateToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :reservation_date, :date
  end
end
