class FixSmsSending < ActiveRecord::Migration
  def up
    rename_column :sms_sendings, :contact_group_id, :sms_group_id
    remove_column :sms_sendings, :status_id
    add_column :sms_sendings, :status, :boolean
    rename_column :sms_sendings, :send_an, :sending_at
  end

  def down
    rename_column :sms_sendings, :sms_group_id, :contact_group_id
    remove_column :sms_sendings, :status
    add_column :sms_sendings, :status_id, :integer
    rename_column :sms_sendings, :sending_at, :send_an
  end
end