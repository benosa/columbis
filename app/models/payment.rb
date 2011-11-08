class Payment < ActiveRecord::Base
  attr_accessible :claim_id, :date_in, :form, :payer_id, :payer_type, :recipient_id, :recipient_type, :currency, :amount, :description

  belongs_to :claim
  belongs_to :payer, :polymorphic => true
  belongs_to :recipient, :polymorphic => true

  validates_presence_of :amount, :form, :currency
  validates_presence_of :recipient_id, :recipient_type
  validates_numericality_of :amount
  validates_inclusion_of :form, :in => DropdownValue.values_for_form

  validates :currency, :inclusion => CurrencyCourse::CURRENCIES

  validate :check_counteragents
  def check_counteragents
    errors.add(:payer, I18n.t('.payer_blank')) unless self.payer
    errors.add(:recipient, I18n.t('.recipient_blank')) unless self.recipient
  end

end
