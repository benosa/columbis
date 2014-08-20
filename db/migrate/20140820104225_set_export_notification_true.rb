class SetExportNotificationTrue < ActiveRecord::Migration
  def up
    change_column :users, :export_notification, :boolean, :default => true, :null => false
    User.where(:role => 'boss').update_all(:export_notification => true)
  end
end
