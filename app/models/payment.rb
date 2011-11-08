class Payment < ActiveRecord::Base
  attr_accessible :claim_id, :date_in, :form, :payer_id, :payer_type, :recipient_id, :recipient_type, :currency, :amount, :description

  belongs_to :claim
  belongs_to :payer, :polymorphic => true
  belongs_to :recipient, :polymorphic => true

  validates_presence_of :amount, :form, :currency
  validates_numericality_of :amount
  validates :currency, :inclusion => CurrencyCourse::CURRENCIES
end
