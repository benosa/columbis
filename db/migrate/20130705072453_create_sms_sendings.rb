class CreateSmsSendings < ActiveRecord::Migration
  def change
    create_table :sms_sendings do |t|
      t.integer :company_id
      t.datetime :send_an
      t.string :signature
      t.integer :contact_group_id
      t.string :content
      t.integer :count
      t.integer :status_id
      t.boolean :sending_priority
      t.integer :user_id
      t.integer :delivered_count

      t.timestamps
    end
  end
end
