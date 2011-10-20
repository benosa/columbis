class Payment < ActiveRecord::Base
  attr_accessible :claim_id, :date_in, :payer_id, :payer_type, :recipient_id, :recipient_type, :currency, :amount, :description 
  
  belongs_to :claim 
  belongs_to :payer, :polymorphic => true
  belongs_to :recipient, :polymorphic => true
  
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :currency
  validates :currency, :inclusion => CurrencyCourse::CURRENCIES
end

