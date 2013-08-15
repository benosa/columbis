class CreateTariffPlans < ActiveRecord::Migration
  def change
    create_table :tariff_plans do |t|
      t.integer :price, :default => 0, :null => false
      t.string :currency, :null => false, :default => 'rur'
      t.string :name, :null => false
      t.boolean :active, :null => false, :default => true
      t.integer :users_count, :null => false
      t.string :place_size, :null => false
      t.boolean :back_office, :default => false, :null => false
      t.boolean :documents_flow, :default => false, :null => false
      t.boolean :claims_base, :default => false, :null => false
      t.boolean :crm_system, :default => false, :null => false
      t.boolean :managers_reminder, :default => false, :null => false
      t.boolean :analytics, :default => false, :null => false
      t.boolean :boss_desktop, :default => false, :null => false
      t.boolean :sms_sending, :default => false, :null => false

      t.timestamps
    end
  end
end