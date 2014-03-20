class UnsetReturnCallByDefault < ActiveRecord::Migration
  def change
    change_column :claims, :return_call, :boolean, :default => false, :null => false
  end
end
