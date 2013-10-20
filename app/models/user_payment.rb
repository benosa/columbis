class UserPayment < ActiveRecord::Base
  attr_accessible :amount, :approved, :company_id, :currency, :description, :invoice, :period, :tariff_id, :user_id
end
