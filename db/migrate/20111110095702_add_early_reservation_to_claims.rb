class AddEarlyReservationToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :early_reservation, :boolean
    add_column :claims, :docs_memo, :string
    add_column :claims, :docs_ticket, :string
    add_column :claims, :docs_note, :string
  end
end
