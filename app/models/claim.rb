class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved passport_received].freeze
  attr_accessible :user_id, :check_date, :description, :office_id, :operator_id, :operator_confirmation, :visa, :visa_check,
                  :airport_to, :airport_back, :flight_to, :flight_back, :depart_to, :depart_back, :time_to, :time_back,
                  :total_tour_price, :course, :fuel_tax_price, :additional_insurance_price, :primary_currency_price,
                  :visa_price, :insurance_price, :tour_price, :currency

  belongs_to :user
  belongs_to :office

  has_many :tourist_claims, :dependent => :destroy, :conditions => { :applicant => false }
  has_many :dependents, :through => :tourist_claims, :source => :tourist

  has_one :tourist_claim, :dependent => :destroy, :conditions => { :applicant => true }
  has_one :applicant, :through => :tourist_claim, :source => :tourist

  has_many :payments_in, :class_name => 'Payment', :conditions => { :recipient_type => 'Company' }
  has_many :payments_out, :class_name => 'Payment', :conditions => { :payer_type => 'Company' }

  accepts_nested_attributes_for :payments_in
  accepts_nested_attributes_for :payments_out

  validates_presence_of :user_id
  validates_presence_of :check_date
  validates_presence_of :currency
  validates_presence_of :applicant
  validates_inclusion_of :currency, :in => CurrencyCourse::CURRENCIES

  def assign_reflections_and_save(claim_params)
    self.transaction do
      drop_reflections
      self.assign_applicant(claim_params[:applicant])
#      self.assign_tourists(claim_params[:tourists])
      self.assign_payments(claim_params[:payments_in_attributes], claim_params[:payments_out_attributes])

      if self.valid?
        remove_unused_payments
        self.save
      end
    end
  end

  def assign_applicant(applicant_params)
    if applicant_params[:id].blank?
      self.applicant = Tourist.create(applicant_params)
    else
      self.applicant = Tourist.find(applicant_params[:id])
    end
  end

  def assign_payments(payments_in, payments_out)
    payments_in.each do |num, payment_hash|
      next if empty_payment_hash?(payment_hash)

      payment_hash[:currency] = CurrencyCourse::PRIMARY_CURRENCY
      payment_hash[:form] = DropdownValue.values_for_form.first
      payment_hash[:recipient_id] = Company.first.try(:id)
      payment_hash[:recipient_type] = Company.first.class.try(:name)
      payment_hash[:payer_id] = self.applicant.try(:id)
      payment_hash[:payer_type] = self.applicant.class.try(:name)
      if payment_hash[:id].blank?
        self.payments_in << Payment.create(payment_hash)
      else
        self.payments_in << Payment.find(payment_hash[:id]).update_attributes(payment_hash)
      end
    end

    payments_out.each do |num, payment_hash|
      next if empty_payment_hash?(payment_hash)

      payment_hash[:currency] = CurrencyCourse::PRIMARY_CURRENCY
      payment_hash[:recipient_id] = Company.first.try(:id)
      payment_hash[:recipient_type] = Company.first.class.try(:name)
      payment_hash[:payer_id] = self.applicant.try(:id)
      payment_hash[:payer_type] = self.applicant.class.try(:name)
      if payment_hash[:id].blank?
        self.payments_out << Payment.create(payment_hash)
      else
        self.payments_out << Payment.find(payment_hash[:id]).update_attributes(payment_hash)
      end
    end
  end

  def assign_tourists(tourists)
    tourists.each do |num, tourist_hash|
      if tourist_hash[:id].blank?
        self.tourists << Tourist.create(tourist_hash)
      else
        self.tourists << Tourist.find(tourist_hash[:id])
      end
    end
  end

  def tourist_debt?
    true
  end

  def operators_debt?
    false
  end

  def documents_ready?
    true
  end

  private

  def remove_unused_payments
    Payment.where(:claim_id => nil).destroy_all
  end

  def empty_payment_hash?(ph)
    ph[:date_in].blank? and ph[:amount].to_f == 0.0 and ph[:id].blank?
  end

  def drop_reflections
    self.dependents = []
    self.payments_in = []
    self.payments_out = []
  end
end
