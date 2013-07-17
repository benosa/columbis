class FixCurrencyInPayments < ActiveRecord::Migration
  class Claim < ActiveRecord::Base; end
  class Payment < ActiveRecord::Base
  	belongs_to :claim
  end

  def up
  	payments = Payment.joins(:claim)
  		.where("payments.payer_type = 'Company' and claims.operator_price_currency != 'rur' and payments.currency = 'rur'")
  		.select('payments.id, claims.operator_price_currency')
  	payments.find_each do |payment|
  		payment.update_column :currency, payment.operator_price_currency
  	end
  end

  def down
  end
end
