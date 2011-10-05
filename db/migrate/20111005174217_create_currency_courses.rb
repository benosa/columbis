class CreateCurrencyCourses < ActiveRecord::Migration
  def self.up
    create_table :currency_courses do |t|
      t.belongs_to :user
      t.datetime :on_date, :null => false
      t.string :currency, :null => false
      t.float :course, :default => 0.0, :null => false
      t.timestamps
    end
    add_index :currency_courses, [:currency, :on_date]
  end

  def self.down
    drop_table :currency_courses
  end
end

