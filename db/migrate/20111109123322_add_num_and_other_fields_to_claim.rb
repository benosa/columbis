# -*- encoding : utf-8 -*-
class AddNumAndOtherFieldsToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :airline_id, :integer
    add_column :claims, :num, :integer
    add_index :claims, :num
    add_column :claims, :visa_count, :integer
    add_column :claims, :meals, :string
    add_column :claims, :placement, :string
    add_column :claims, :nights, :integer
    add_column :claims, :hotel, :string
    add_column :claims, :arrival_date, :datetime
    add_column :claims, :departure_date, :datetime
  end
end
