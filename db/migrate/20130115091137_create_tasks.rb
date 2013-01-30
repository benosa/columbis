class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
    	t.integer :author
    	t.text :body
    	t.string :status
    	t.integer :executer
    	t.datetime :start_date 
    	t.datetime :end_date
    	t.boolean :bug, :default => false
      t.timestamps
    end
  end
end
