class ChangeDateTypeInClaims < ActiveRecord::Migration
  def self.up
    change_column :claims, :arrival_date, :date
    change_column :claims, :departure_date, :date
    change_column :claims, :check_date, :date
    change_column :claims, :visa_check, :date
  end

  def self.down
    change_column :claims, :arrival_date, :datetime
    change_column :claims, :departure_date, :datetime
    change_column :claims, :check_date, :datetime
    change_column :claims, :visa_check, :datetime
  end
end
