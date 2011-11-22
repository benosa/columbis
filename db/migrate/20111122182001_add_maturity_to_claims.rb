class AddMaturityToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :maturity, :date
  end
end
