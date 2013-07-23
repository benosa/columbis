class CreateSmsGroups < ActiveRecord::Migration
  def change
    create_table :sms_groups do |t|
      t.integer :company_id
      t.string :name
      t.integer :contact_count

      t.timestamps
    end
  end
end
