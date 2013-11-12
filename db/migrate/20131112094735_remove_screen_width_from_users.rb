class RemoveScreenWidthFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :screen_width
  end

  def down
    add_column :users, :screen_width, :string
  end
end
