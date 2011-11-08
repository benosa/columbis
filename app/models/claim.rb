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

      self.save
    end
  end

  def assign_payments(payments_in, payments_out)
    payments_in.each do |num, payment_hash|
      if payment_hash[:id].blank?
        #TODO add req. keys in hash
        self.payments << Payment.create(payment_hash)
      else
        self.payments << Payment.find(payment_hash[:id])
      end
    end
    #TODO: remove unused payments

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

  def assign_applicant(applicant_params)
    if applicant_params[:id].blank?
      tourist = Tourist.new(applicant_params)
      if tourist.save
        self.applicant = tourist
      else
        tourist.errors.messages.each do |attr_name, err|
          self.errors.add(:applicant, I18n.t("tourist.#{attr_name.to_s}" ) + " : " + err.join(', '))
        end
      end
    else
      applicant = Tourist.find(applicant_params[:id])
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

  def drop_reflections
    self.applicant = nil
    self.dependents = []
    self.payments_in = []
    self.payments_out = []
  end
end
