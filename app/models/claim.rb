class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved passport_received].freeze
  attr_accessible :user_id, :airline_id, :country_id, :check_date, :description, :office_id, :operator_id, :operator_confirmation,
                  :visa, :visa_check, :visa_count,
                  :airport_to, :airport_back, :flight_to, :flight_back, :depart_to, :depart_back, :time_to, :time_back,
                  :total_tour_price, :course, :fuel_tax_price, :additional_insurance_price, :primary_currency_price,
                  :visa_price, :insurance_price, :tour_price, :currency, :num, :meals, :hotel, :placement, :nights, :memo,
                  :arrival_date, :departure_date, :early_reservation, :docs_memo, :docs_ticket, :docs_note, :reservation_date

  belongs_to :user
  belongs_to :office
  belongs_to :airline
  belongs_to :operator
  belongs_to :country
  belongs_to :city

  has_many :tourist_claims, :dependent => :destroy, :conditions => { :applicant => false }
  has_many :dependents, :through => :tourist_claims, :source => :tourist

  has_one :tourist_claim, :dependent => :destroy, :conditions => { :applicant => true }
  has_one :applicant, :through => :tourist_claim, :source => :tourist

  has_many :payments_in, :class_name => 'Payment', :conditions => { :recipient_type => 'Company' }
  has_many :payments_out, :class_name => 'Payment', :conditions => { :payer_type => 'Company' }

  accepts_nested_attributes_for :dependents
  accepts_nested_attributes_for :payments_in
  accepts_nested_attributes_for :payments_out

  validates_uniqueness_of :num
  validates_presence_of :num
  validates_presence_of :user_id, :office_id
  validates_presence_of :check_date
  validates_presence_of :currency
  validates_inclusion_of :currency, :in => CurrencyCourse::CURRENCIES

  validate :presence_of_applicant

  def assign_reflections_and_save(claim_params)
    self.transaction do
      drop_reflections
      check_dropdowns(claim_params)

      self.assign_applicant(claim_params[:applicant])
      self.assign_dependents(claim_params[:dependents_attributes]) if claim_params.has_key?(:dependents_attributes)
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

  def assign_dependents(tourists)
    tourists.each do |num, tourist_hash|
      next if empty_tourist_hash?(tourist_hash)
      if tourist_hash[:id].blank?
        self.dependents << Tourist.create(tourist_hash)
      else
        tourist = Tourist.find(tourist_hash[:id])
        tourist.update_attributes(tourist_hash)
        self.dependents << tourist
      end
    end
  end

  def assign_payments(payments_in, payments_out)
    payments_in.each do |num, payment_hash|
      next if empty_payment_hash?(payment_hash)

#      payment_hash[:currency] = CurrencyCourse::PRIMARY_CURRENCY
      payment_hash[:form] = DropdownValue.values_for_form.first
      payment_hash[:recipient_id] = Company.first.try(:id)
      payment_hash[:recipient_type] = Company.first.class.try(:name)
      payment_hash[:payer_id] = self.applicant.try(:id)
      payment_hash[:payer_type] = self.applicant.class.try(:name)

      process_payment_hash(payment_hash, self.payments_in)
    end

    payments_out.each do |num, payment_hash|
      next if empty_payment_hash?(payment_hash)

#      payment_hash[:currency] = CurrencyCourse::PRIMARY_CURRENCY
      payment_hash[:recipient_id] = Company.first.try(:id)
      payment_hash[:recipient_type] = Company.first.class.try(:name)
      payment_hash[:payer_id] = self.applicant.try(:id)
      payment_hash[:payer_type] = self.applicant.class.try(:name)

      process_payment_hash(payment_hash, self.payments_out)
    end
  end

  def tourist_debt?
    true
  end

  def operator_debt?
    false
  end

  def documents_ready?
    true
  end

  def has_notes?
    !self.docs_note.blank?
  end

  def set_new_num
    self.num = Claim.last.try(:num).to_i + 1
  end

  def fill
    self.applicant = Tourist.new
    self.payments_in << Payment.new
    self.payments_out << Payment.new
    self.set_new_num
  end

  private

  def remove_unused_payments
    Payment.where(:claim_id => nil).destroy_all
  end

  def process_payment_hash(ph, payments)
    DropdownValue.check_and_save('form', ph[:form])
    if ph[:id].blank?
      payments << Payment.create(ph)
    else
      payment = Payment.find(ph[:id])
      payment.update_attributes(ph)
      payments << payment
    end
  end

  def empty_tourist_hash?(th)
    th[:passport_number].blank? and th[:passport_valid_until].blank? and th[:id].blank? and
    th[:passport_series].blank? and th[:full_name].blank? and th[:date_of_birth].blank?
  end

  def empty_payment_hash?(ph)
    ph[:date_in].blank? and ph[:amount].to_f == 0.0 and ph[:id].blank?
  end

  def drop_reflections
    self.dependents = []
    self.payments_in = []
    self.payments_out = []
  end

  def check_dropdowns(claim_params)
    lists = %w[meals hotel placement]
    lists.each do |l|
      DropdownValue.check_and_save(l, claim_params[l.to_sym])
    end

    DropdownValue.check_and_save('airport', claim_params[:airport_to])
    DropdownValue.check_and_save('airport', claim_params[:airport_back])

    Airline.create({ :name => claim_params[:airline] }) unless Airline.find_by_name(claim_params[:airline])
    self.airline = Airline.where( :name => claim_params[:airline]).first

    Operator.create({ :name => claim_params[:operator] }) unless Operator.find_by_name(claim_params[:operator])
    self.operator = Operator.where( :name => claim_params[:operator]).first
  end

  def presence_of_applicant
    errors.add(:applicant, I18n.t('.applicant_blank_or_wrong')) unless self.applicant.valid?
  end
end
