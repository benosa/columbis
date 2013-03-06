class ChangeParentIdToUserMailer < ActiveRecord::Migration
  def change
    change_column :user_mailers, :parent_id, :string
  end
end
