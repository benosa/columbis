class AddTariffToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :tariff_id, :integer
    add_column :companies, :user_payment_id, :integer
    add_column :companies, :tariff_end, :datetime
    add_column :companies, :paid, :float
  end
end
