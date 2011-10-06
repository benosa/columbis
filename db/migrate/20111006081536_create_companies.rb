class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :title
      t.string :email
      t.string :oficial_letter_signature
      t.integer :country_id
      t.integer :city_id

      t.timestamps
    end
  end
end
