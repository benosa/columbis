class AddAdminNoteToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :admin_note, :text
  end
end
