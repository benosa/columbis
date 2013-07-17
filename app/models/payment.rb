# -*- encoding : utf-8 -*-
class Payment < ActiveRecord::Base
  attr_accessible :claim_id, :date_in, :form, :payer_id, :payer_type, :recipient_id, :course, :reversed_course,
                  :recipient_type, :currency, :amount, :amount_prim, :description, :approved, :canceled
  attr_protected :company_id

  belongs_to :company
  belongs_to :claim
  belongs_to :payer, :polymorphic => true
  belongs_to :recipient, :polymorphic => true

  # validates_presence_of :claim # in claim inveres_of option must be used
  validates_presence_of :amount, :amount_prim, :form, :currency, :date_in, :course
  # validates_presence_of :recipient_id, :recipient_type, :payer_id, :payer_type

  validates_numericality_of :course, :amount
  # validates_numericality_of :course, :amount, :greater_than => 0

  # validates_inclusion_of :form, :in => Proc.new { |p| DropdownValue.values_for('form', p.company) }

  validates :currency, :inclusion => CurrencyCourse::CURRENCIES

  validate :check_counteragents
  def check_counteragents
    errors.add(:payer, I18n.t('errors.messages.blank')) unless self.payer
    errors.add(:recipient, I18n.t('errors.messages.blank')) unless self.recipient
  end

  before_save :fill_fields
  before_save do |payment|
    company.check_and_save_dropdown('form', payment.form)
  end

  scope :approved, -> { where(:approved => true) }

  private

    def fill_fields
      # we also store amount in primary currency
      crs = reversed_course ? (course != 0 ? 1 / course : 0) : course
      self.amount_prim = (crs * amount).round(2)
      self.description = amount.to_f.amount_in_words(currency)[0,255] # Limit string length to database field length to avoid errors
    end
end
