class AddLockFieldsToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :locked_by, :integer
    add_column :claims, :locked_at, :datetime
  end
end
