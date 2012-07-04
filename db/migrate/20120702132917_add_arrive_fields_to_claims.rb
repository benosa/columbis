class AddArriveFieldsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :arrive_to, :datetime
    add_column :claims, :arrive_back, :datetime
  end
end
