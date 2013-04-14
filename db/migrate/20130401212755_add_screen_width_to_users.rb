class AddScreenWidthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :screen_width, :string
  end
end
