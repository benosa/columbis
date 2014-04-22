class CreateCompanyOperators < ActiveRecord::Migration
  def self.up
    create_table :company_operators do |t|
      t.integer :company_id
      t.integer :operator_id
      t.timestamps
    end
  end

  def self.down
    drop_table :company_operators
  end
end
