class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.integer :company_id
      t.integer :user_id
      t.string :name
      t.string :title
      t.integer :position
      t.string :view
      t.text :settings
      t.string :widget_type

      t.timestamps
    end
  end
end
