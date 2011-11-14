class AddMemoToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :memo, :string
  end
end
