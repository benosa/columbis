class AddKppToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :kpp, :integer
  end
end
