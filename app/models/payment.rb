class Payment < ActiveRecord::Base
  attr_accessible :claim_id, :date_in, :form, :payer_id, :payer_type, :recipient_id, :course,
                  :recipient_type, :currency, :amount, :amount_prim, :description, :approved

  belongs_to :claim
  belongs_to :payer, :polymorphic => true
  belongs_to :recipient, :polymorphic => true

  validates_presence_of :amount, :amount_prim, :form, :currency, :claim_id, :date_in
  validates_presence_of :recipient_id, :recipient_type, :payer_id, :payer_type
  validates_numericality_of :amount, :amount_prim
  validates_inclusion_of :form, :in => DropdownValue.values_for_form

  validates :currency, :inclusion => CurrencyCourse::CURRENCIES

  validate :check_counteragents
  def check_counteragents
    errors.add(:payer, I18n.t('.payer_blank')) unless self.payer
    errors.add(:recipient, I18n.t('.recipient_blank')) unless self.recipient
  end

  before_save :fill_fields
  def fill_fields
    # we also store amount in primary currency
    self.amount_prim = (self.course * self.amount).round
    self.description = RuPropisju.amount_in_word(self.amount, self.currency)
  end
end
