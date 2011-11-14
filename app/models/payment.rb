class Payment < ActiveRecord::Base
  attr_accessible :claim_id, :date_in, :form, :payer_id, :payer_type, :recipient_id,
                  :recipient_type, :currency, :amount, :amount_prim, :description

  belongs_to :claim
  belongs_to :payer, :polymorphic => true
  belongs_to :recipient, :polymorphic => true

  validates_presence_of :amount, :amount_prim, :form, :currency
  validates_presence_of :recipient_id, :recipient_type
  validates_numericality_of :amount, :amount_prim
  validates_inclusion_of :form, :in => DropdownValue.values_for_form

  validates :currency, :inclusion => CurrencyCourse::CURRENCIES

  validate :check_counteragents
  def check_counteragents
    errors.add(:payer, I18n.t('.payer_blank')) unless self.payer
    errors.add(:recipient, I18n.t('.recipient_blank')) unless self.recipient
  end

  def before_save
    # we also store amount in primary currency
    if self.currency == CurrencyCourse::PRIMARY_CURRENCY
      self.amount_prim = self.amount
    else
      self.amount_prim = CurrencyCourse.convert_from_curr_to_curr(self.currency, CurrencyCourse::PRIMARY_CURRENCY, self.amount)
    end
    raise self.inspect
  end
end
