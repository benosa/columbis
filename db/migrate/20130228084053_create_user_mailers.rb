class CreateUserMailers < ActiveRecord::Migration
  def change
    create_table :user_mailers do |t|
      t.string :title
      t.text :body
      t.integer :parent_id
      t.integer :message_id
      t.integer :task_id
      t.timestamps
    end
  end
end
