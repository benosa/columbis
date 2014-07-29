class AddExportNotificationToUser < ActiveRecord::Migration
  def change
    add_column :users, :export_notification, :boolean, :default => false, :null => false
  end
end
