class AddOperatorMaturityToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :operator_maturity, :date
  end
end
