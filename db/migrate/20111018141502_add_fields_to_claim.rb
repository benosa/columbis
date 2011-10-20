class AddFieldsToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :office_id, :integer
    add_column :claims, :operator_id, :integer
    add_column :claims, :operator_confirmation, :string
    add_column :claims, :visa, :datetime    
    add_column :claims, :airport_to, :string
    add_column :claims, :airport_back, :string
    add_column :claims, :flight_to, :string
    add_column :claims, :flight_back, :string
    add_column :claims, :depart_to, :string
    add_column :claims, :depart_back, :string
    add_column :claims, :time_to, :time
    add_column :claims, :time_back, :time
  end
end
