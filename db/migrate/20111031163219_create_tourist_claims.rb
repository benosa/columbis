class CreateTouristClaims < ActiveRecord::Migration
  def self.up
    create_table :tourist_claims do |t|
      t.integer :claim_id
      t.integer :tourist_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tourist_claims
  end
end
