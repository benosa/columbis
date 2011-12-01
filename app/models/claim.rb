class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved passport_received].freeze
  # relations
  attr_accessible :user_id,:office_id, :operator_id, :airline_id, :country_id, :resort_id, :city_id

  # price block
  attr_accessible :tour_price, :visa_price, :visa_count, :insurance_price, :additional_insurance_price, :fuel_tax_price,
                  :primary_currency_price, :course_eur, :course_usd, :tour_price_currency, :visa_price_currency,
                  :insurance_price_currency, :additional_insurance_price_currency, :fuel_tax_price_currency, :calculation

  # flight block
  attr_accessible :airport_to,  :airport_back, :flight_to, :flight_back, :depart_to, :depart_back

  # marchroute block
  attr_accessible :meals, :placement, :nights, :hotel, :arrival_date, :departure_date, :memo

  # common
  attr_accessible :reservation_date, :visa, :visa_check, :visa_confirmation_flag, :check_date, :operator_confirmation,
                  :early_reservation, :docs_memo, :docs_ticket, :docs_note

  # amounts and payments
  attr_accessible :operator_price, :operator_price_currency, :operator_debt, :tourist_debt,
                  :maturity, :tourist_advance, :tourist_paid


  belongs_to :user
  belongs_to :office
  belongs_to :airline
  belongs_to :operator
  belongs_to :country
  belongs_to :city
  belongs_to :resort, :class_name => 'City'

  has_many :tourist_claims, :dependent => :destroy, :conditions => { :applicant => false }
  has_many :dependents, :through => :tourist_claims, :source => :tourist

  has_one :tourist_claim, :dependent => :destroy, :conditions => { :applicant => true }
  has_one :applicant, :through => :tourist_claim, :source => :tourist

  has_many :payments_in, :class_name => 'Payment', :conditions => { :recipient_type => 'Company' }
  has_many :payments_out, :class_name => 'Payment', :conditions => { :payer_type => 'Company' }

  accepts_nested_attributes_for :dependents
  accepts_nested_attributes_for :payments_in
  accepts_nested_attributes_for :payments_out

  validates_presence_of :user_id,:office_id, :operator_id, :airline_id, :country_id, :resort_id, :city_id
  validates_presence_of :airport_to,  :airport_back, :flight_to, :flight_back, :depart_to, :depart_back
  validates_presence_of :tour_price_currency, :visa_price_currency, :insurance_price_currency,
                        :additional_insurance_price_currency, :fuel_tax_price_currency, :operator_price_currency

  [:tour_price_currency, :visa_price_currency, :insurance_price_currency, :additional_insurance_price_currency, :fuel_tax_price_currency, :operator_price_currency].each do |a|
    validates_inclusion_of a, :in => CurrencyCourse::CURRENCIES
  end

  validate :presence_of_applicant
  validate :correctness_of_maturity

  before_save :update_debts

  define_index do
    indexes airport_to, airport_back, flight_to, flight_back, meals, placement, hotel, memo

    indexes user(:last_name), :as => :user, :sortable => true
    indexes office(:name), :as => :office, :sortable => true
    indexes operator(:name), :as => :operator, :sortable => true
    indexes country(:name), :as => :country, :sortable => true
    indexes city(:name), :as => :city, :sortable => true
    indexes resort(:name), :as => :resort, :sortable => true

    indexes [dependents.last_name, dependents.first_name], :as => :dependents, :sortable => true
    indexes [applicant.last_name, applicant.first_name], :as => :applicant

    set_property :delta => true
  end

  def self.search_and_sort(options = {})
    options = { :filter => '', :column => 'id', :direction => 'asc' }.merge(options)
    ids = search(options[:filter]).map(&:id)
    where('id in(?)', ids).order(options[:column] + ' ' + options[:direction])
  end

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
    tourists.each do |key, tourist_hash|
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
    payments_in.each do |key, payment_hash|
      next if empty_payment_hash?(payment_hash)

      payment_hash[:form] = DropdownValue.values_for_form.first
      payment_hash[:recipient_id] = Company.first.try(:id)
      payment_hash[:recipient_type] = Company.first.class.try(:name)
      payment_hash[:payer_id] = self.applicant.try(:id)
      payment_hash[:payer_type] = self.applicant.class.try(:name)

      process_payment_hash(payment_hash, self.payments_in)
    end

    payments_out.each do |key, payment_hash|
      next if empty_payment_hash?(payment_hash)

      payment_hash[:recipient_id] = self.operator.try(:id)
      payment_hash[:recipient_type] = self.operator.class.try(:name)
      payment_hash[:payer_id] = Company.first.try(:id)
      payment_hash[:payer_type] = Company.first.class.try(:name)

      process_payment_hash(payment_hash, self.payments_out)
    end
  end

  def has_tourist_debt?
    self.tourist_debt != 0
  end

  def has_operator_debt?
    self.operator_debt != 0
  end

  def documents_ready?
    true
  end

  def has_notes?
    !self.docs_note.blank?
  end

  def fill_new
    self.applicant = Tourist.new
    self.payments_in << Payment.new
    self.payments_out << Payment.new

    self.reservation_date = Date.today
    self.maturity = Date.today + 3.days
  end

  def self.next_id
    Claim.last.try(:id).to_i + 1
  end

  def flight_status
    day_of_week = depart_to.to_a[6]
    day_of_week = 7 if day_of_week == 0

    monday = (depart_to.to_date - (day_of_week - 1).days).to_time

    puts Time.now
    puts monday
    puts depart_to

    if monday > Time.now
     'soon'
    elsif (monday < Time.now and depart_to > Time.now) or (depart_to < Time.now)
      'hot'
    else
      'departed'
    end
  end

  private

  def update_debts
    self.operator_debt = (CurrencyCourse.convert_from_curr_to_curr(
      self.operator_price_currency, CurrencyCourse::PRIMARY_CURRENCY, self.operator_price)) - self.payments_out.sum('amount_prim')

    self.tourist_advance = self.payments_in.sum('amount_prim')

    self.tourist_debt = self.primary_currency_price - self.tourist_advance
    self.tourist_paid = create_paid_string
  end

  def create_paid_string
    str = ''
    CurrencyCourse::CURRENCIES.each do |cur|
      payment_amount = self.payments_in.sum(:amount, :conditions => "currency = '#{cur}'")
      (str += cur.upcase << ': ' << payment_amount.to_s << ' ') unless payment_amount == 0.0
    end
    str.strip!
  end

  def create_calculation_string
    str = ''

    str.strip!
  end

  def remove_unused_payments
    Payment.where(:claim_id => nil).destroy_all
  end

  def process_payment_hash(ph, in_out_payments)
    DropdownValue.check_and_save('form', ph[:form])
    if ph[:id].blank?
      in_out_payments << Payment.create(ph)
    else
      payment = Payment.find(ph[:id])
      payment.update_attributes(ph)
      in_out_payments << payment
    end
  end

  def empty_tourist_hash?(th)
    th = th.symbolize_keys
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

    Country.create({ :name => claim_params[:country] }) unless Country.find_by_name(claim_params[:country])
    self.country = Country.where( :name => claim_params[:country]).first

    City.create({ :name => claim_params[:city] }) unless City.find_by_name(claim_params[:city])
    self.city = City.where( :name => claim_params[:city]).first

    City.create({ :name => claim_params[:resort] }) unless City.find_by_name(claim_params[:resort])
    self.resort = City.where( :name => claim_params[:resort]).first
  end

  def presence_of_applicant
    errors.add(:applicant, I18n.t('.applicant_blank_or_wrong')) unless self.applicant.valid?
  end

  def correctness_of_maturity
    errors.add(:maturity, I18n.t('.applicant_blank_or_wrong')) unless self.applicant.valid?
  end
end
