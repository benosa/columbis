class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :file
      t.belongs_to :imageable, polymorphic: true
      t.timestamps
    end
  end
end
