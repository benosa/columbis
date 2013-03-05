class ChangeMessageIdToUserMailer < ActiveRecord::Migration
  def change
    change_column :user_mailers, :message_id, :string
  end
end
