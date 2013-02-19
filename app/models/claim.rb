# -*- encoding : utf-8 -*-
class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved all_done].freeze
  DOCUMENTS_STATUSES = %w[not_ready received all_done].freeze
  DEFAULT_SORT = { :col => 'reservation_date', :dir => 'desc' }.freeze

  # relations
  attr_protected :user_id, :company_id, :office_id, :operator_id, :resort_id, :city_id, :country_id

  # price block
  attr_accessible :tour_price, :tour_price_currency, :additional_services_price_currency,
                  :visa_price, :visa_count, :visa_price_currency,
                  :children_visa_price, :children_visa_count, :children_visa_price_currency,
                  :insurance_price, :insurance_count, :insurance_price_currency,
                  :additional_insurance_price, :additional_insurance_count,  :additional_insurance_price_currency,
                  :fuel_tax_price, :fuel_tax_count, :fuel_tax_price_currency,
                  :primary_currency_price, :course_eur, :course_usd, :calculation

  # flight block
  attr_accessible :airline, :airport_to,  :airport_back, :flight_to, :flight_back, :depart_to, :depart_back,
                  :arrive_to, :arrive_back

  # marchroute block
  attr_accessible :meals, :placement, :nights, :hotel, :arrival_date, :departure_date,
                  :memo, :transfer, :relocation, :service_class, :additional_services, :medical_insurance

  # common
  attr_accessible :reservation_date, :visa, :visa_check, :visa_confirmation_flag, :check_date,
                  :operator_confirmation, :operator_confirmation_flag, :early_reservation, :documents_status,
                  :docs_note, :closed, :memo_tasks_done, :canceled, :tourist_stat, :assistant_id


  # amounts and payments
  attr_accessible :operator_price, :operator_price_currency, :operator_debt, :tourist_debt,
                  :maturity, :tourist_advance, :tourist_paid, :operator_advance, :operator_paid,
                  :additional_services_price, :additional_services_currency, :operator_maturity,
                  :profit, :profit_in_percent, :approved_operator_advance, :approved_tourist_advance,
                  :bonus, :bonus_percent
                  #:payments_in_attributes, :payments_out_attributes

  belongs_to :company
  belongs_to :user
  belongs_to :assistant, :class_name => 'User'
  belongs_to :office
  belongs_to :operator
  belongs_to :country
  belongs_to :city
  belongs_to :resort, :class_name => 'City'

  has_many :tourist_claims, :dependent => :destroy, :conditions => { :applicant => false }
  has_many :dependents, :through => :tourist_claims, :source => :tourist

  has_one :tourist_claim, :dependent => :destroy, :conditions => { :applicant => true }
  has_one :applicant, :through => :tourist_claim, :source => :tourist

  has_many :payments_in, :class_name => 'Payment', :conditions => { :recipient_type => 'Company' }, :inverse_of => :claim
  has_many :payments_out, :class_name => 'Payment', :conditions => { :payer_type => 'Company' }, :inverse_of => :claim

  accepts_nested_attributes_for :dependents
  accepts_nested_attributes_for :payments_in, :reject_if => :empty_payment_hash?
  accepts_nested_attributes_for :payments_out, :reject_if => :empty_payment_hash?

  validates_presence_of :user_id, :operator_id, :check_date, :arrival_date
  # validates_presence_of :user_id, :operator_id, :office_id, :country_id, :resort_id, :city_id
  # validates_presence_of :check_date, :tourist_stat, :arrival_date, :departure_date, :maturity,
  #                       :airline, :airport_to, :airport_back,
  #                       :tour_price, :hotel, :meals, :medical_insurance,
  #                       :placement, :transfer, :service_class, :relocation

  # validates_presence_of :operator_confirmation, :operator_maturity, :if => Proc.new { |claim| claim.operator_confirmation_flag }

  [:tour_price_currency, :visa_price_currency, :insurance_price_currency, :additional_insurance_price_currency, :fuel_tax_price_currency, :operator_price_currency].each do |a|
    # validates_presence_of a
    validates_inclusion_of a, :in => CurrencyCourse::CURRENCIES
  end

  validate :presence_of_applicant

  before_save :update_debts

  define_index do
    indexes :airport_to, :airport_back, :visa, :calculation, :documents_status, :docs_note, :flight_to, :flight_back, :meals, :placement,
            :tourist_stat, :hotel, :memo, :transfer, :relocation, :service_class, :additional_services,
            :operator_confirmation, :sortable => true

    # indexes applicant(:last_name), :as => :applicant_last_name, :sortable => true
    # indexes user(:last_name), :as => :last_name, :sortable => true

    indexes office(:name), :as => :office, :sortable => true
    indexes operator(:name), :as => :operator, :sortable => true
    indexes country(:name), :as => :country, :sortable => true
    indexes city(:name), :as => :city, :sortable => true
    indexes resort(:name), :as => :resort, :sortable => true

    indexes user(:login), :as => :user, :sortable => true
    indexes assistant(:login), :as => :assistant, :sortable => true
    indexes [dependents.last_name, dependents.first_name], :as => :dependents, :sortable => true
    indexes [applicant.last_name, applicant.first_name], :as => :applicant, :sortable => true
    indexes applicant(:phone_number), :as => :phone_number, :sortable => true

    has :id
    has :company_id
    has :office_id
    has :user_id
    has :assistant_id

    has :reservation_date, :depart_to, :depart_back, :visa_check, :check_date,
        :arrival_date, :departure_date, :maturity, :operator_maturity, :type => :datetime
    has :operator_confirmation_flag, :type => :boolean
    has :primary_currency_price, :tourist_advance, :tourist_debt, :operator_price, :operator_advance, :operator_debt,
        :approved_tourist_advance, :approved_operator_advance, :approved_operator_advance_prim, :profit, :profit_in_percent,
        :bonus, :bonus_percent, :type => :float

    set_property :delta => true
  end

  local_data :extra_columns => :local_data_extra_columns, :extra_data => :local_extra_data,
            :columns_filter => :local_data_columns_filter,
            :scope => :local_data_scope

  extend SearchAndSort

  def assign_reflections_and_save(claim_params)
    self.transaction do
      drop_reflections
      check_dropdowns(claim_params)

      assign_applicant(claim_params[:applicant])
      assign_dependents(claim_params[:dependents_attributes]) if claim_params.has_key?(:dependents_attributes)
      assign_payments_in(claim_params[:payments_in_attributes]) if claim_params.has_key?(:payments_in_attributes) # can be created for a new claim
      assign_payments_out(claim_params[:payments_out_attributes]) if claim_params.has_key?(:payments_out_attributes) and !self.new_record?

      unless self.errors.any?
        remove_unused_payments
        check_not_null_fields
        self.save
      end
    end
  end

  def documents_ready?
    self.documents_status == 'all_done'
  end

  def has_tourist_debt?
    self.tourist_debt > 0
  end

  def has_operator_debt?
    self.operator_debt > 0
  end

  def has_memo?
    !self.memo.blank?
  end

  def fill_new
    self.applicant = Tourist.new
    self.payments_in << Payment.new(:currency => CurrencyCourse::PRIMARY_CURRENCY)
    self.payments_out << Payment.new(:currency => CurrencyCourse::PRIMARY_CURRENCY)

    cur_attrs = Hash[[
      :tour_price_currency, :visa_price_currency, :children_visa_price_currency, :insurance_price_currency,
      :additional_insurance_price_currency, :fuel_tax_price_currency, :additional_services_price_currency,
      :operator_price_currency
    ].map{|c| [c, CurrencyCourse::PRIMARY_CURRENCY] }]
    self.attributes = cur_attrs

    self.reservation_date = Date.today
    self.maturity = Date.today + 3.days
  end

  def self.next_id
    Claim.last.try(:id).to_i + 1
  end

  def print_contract
    company.contract_printer.prepare_template(printable_fields, printable_collections)
  end

  def print_memo
    company.memo_printer_for(country).prepare_template(printable_fields, printable_collections)
  end

  def print_permit
    company.permit_printer.prepare_template(printable_fields, printable_collections)
  end

  def print_warranty
    company.warranty_printer.prepare_template(printable_fields, printable_collections)
  end

  def print_act
    company.act_printer.prepare_template(printable_fields, printable_collections)
  end

  def self.columns_info
    Claim.columns.sort!{ |x,y| x.name <=> y.name }.map{ |c| c.name + ' ' + to_js_type(c.type) }
  end

  def total_tour_price_in_curr
    course(tour_price_currency).round > 0 ? (calculate_tour_price / course(tour_price_currency)).round : 0
  end

  def update_bonus(_percent)
    percent = BigDecimal.new(_percent)
    percent = 0 if percent.nan? or percent < 0
    bonus = profit * percent / 100
    update_attributes(:bonus => bonus, :bonus_percent => percent)
  end

  def self.local_data_extra_columns
    helpers = ClaimsController.helpers
    c = ApplicationController.current

    columns = [
      :tourist_stat_short,
      :user,
      :login,
      :login_short,
      :assistant,
      :assistant_short,
      :tourists_list,
      :initials_name,
      :phone_number,
      :phone_number_short,
      :color_for_flight,
      :depart_to_short,
      :depart_back_short,
      :country,
      :country_short,
      :city,
      :city_short,
      :resort,
      :resort_short,
      :text_for_visa,
      :class_for_visa,
      :visa_check_short,
      :operator,
      :operator_confirmation_short,
      :calculation_short,
      :tourist_advance_class,
      :tourist_debt_class,
      :has_tourist_debt,
      :operator_price_short,
      :operator_price_class,
      :operator_maturity_short,
      :operator_advance_short,
      :operator_advance_class,
      :operator_debt_short,
      :operator_debt_class,
      :has_operator_debt,
      :documents_ready,
      :documents_status_class,
      :price_as_string,
      :memo_short,
      :memo_class,
      :check_date_class,

      :applicant_id,
      :dependent_ids
    ]

    if c.is_admin? or c.is_boss? or c.is_supervisor? and c.current_company.offices.count > 1
      columns += [
        :office,
        :office_short
      ]
    end

    if c.can? :switch_view, c.current_user
      columns += [
        :approved_advance_tourist,
        :approved_advance_operator_prim,
        :approved_advance_operator,
        :profit,
        :profit_in_percent
      ]
    end

    columns
  end

  def self.local_data_scope
    c = ApplicationController.current
    self.accessible_by(c.current_ability)
  end

  def self.local_data_columns_filter(column)
    c = ApplicationController.current
    selected = true;

    if column == :office_id
      selected = (c.is_admin? or c.is_boss? or c.is_supervisor?) # and c.current_company.offices.count > 1)
    elsif [:profit, :profit_in_percent].include? column
      selected = c.can? :switch_view, c.current_user
    end

    selected
  end

  def local_extra_data
    helpers = ClaimsController.helpers
    c = ApplicationController.current
    claim = self

    data = {
      :id => id,
      :reservation_date => helpers.l(claim.reservation_date, :format => :default),
      :tourist_stat => claim.tourist_stat,
      :tourist_stat_short => helpers.truncate(claim.tourist_stat, :length => 4),
      :user => claim.user.try(:first_last_name),
      :login => claim.user.try(:login),
      :login_short => helpers.truncate(claim.user.try(:login), :length => 8),
      :assistant => claim.assistant.try(:first_last_name),
      :assistant_short => helpers.truncate(claim.assistant.try(:login), :length => 8),
      :tourists_list => helpers.tourists_list(claim),
      :initials_name => helpers.truncate(claim.applicant.try(:initials_name), :length => 8),
      :phone_number => claim.applicant.try(:phone_number),
      :phone_number_short => helpers.truncate(claim.applicant.try(:phone_number), :length => 10),
      :color_for_flight => helpers.color_for_flight(claim),
      :depart_to_full => helpers.l(claim.depart_to, :format => :long),
      :depart_to_short => helpers.l(claim.depart_to, :format => :short_date),
      :depart_back => helpers.l(claim.depart_back, :format => :long),
      :depart_back_short => helpers.l(claim.depart_back, :format => :short_date),
      :country => claim.country.try(:name),
      :country_short => helpers.truncate(claim.country.try(:name), :length => 8),
      :city => claim.city.try(:name),
      :city_short => helpers.truncate(claim.city.try(:name), :length => 6),
      :resort => claim.resort.try(:name),
      :resort_short => helpers.truncate(claim.resort.try(:name), :length => 6),
      :text_for_visa => helpers.text_for_visa(claim),
      :class_for_visa => (!claim.canceled? && claim.visa_confirmation_flag) && claim.visa,
      :visa_check => helpers.l( claim.visa_check, :format => :long ),
      :visa_check_short => helpers.l( claim.visa_check, :format => :short ),
      :operator => claim.operator.try(:name),
      :operator_confirmation => claim.operator_confirmation,
      :operator_confirmation_short => helpers.truncate(claim.operator_confirmation, :length => 10),
      # :primary_currency_price => claim.primary_currency_price.to_money,
      :calculation => claim.calculation,
      :calculation_short => helpers.truncate(claim.calculation, :length => 8),
      # :tourist_advance => claim.tourist_advance.to_money,
      :tourist_advance_class => helpers.color_for_tourist_advance(claim),
      # :tourist_debt => claim.tourist_debt.to_money,
      :tourist_debt_class => !claim.canceled? && helpers.color_for_tourist_advance(claim),
      :has_tourist_debt => claim.has_tourist_debt?,
      # :operator_price => claim.operator_price.to_money,
      :operator_price_short => claim.operator_price > 0 ? helpers.truncate(helpers.operator_price(claim), :length => 6) : '',
      :operator_price_class => !claim.canceled? && helpers.color_for_operator_price(claim),
      :operator_maturity => helpers.l( claim.operator_maturity, :format => :long ),
      :operator_maturity_short => helpers.l( claim.operator_maturity, :format => :short ),
      # :operator_advance => claim.operator_advance.to_money,
      :operator_advance_short => helpers.operator_advance(claim),
      :operator_advance_class => !claim.canceled? && helpers.color_for_operator_advance(claim),
      # :operator_debt => claim.operator_debt.to_money,
      :operator_debt_short => helpers.operator_debt(claim),
      :operator_debt_class => (!claim.canceled? && claim.operator_debt != 0) && 'red_back',
      :has_operator_debt => claim.has_operator_debt?,
      :documents_ready => claim.documents_ready?,
      :documents_status => helpers.t('claims.form.documents_statuses.' << claim.documents_status),
      :documents_status_class => !claim.canceled? && claim.documents_status,
      :price_as_string => claim.primary_currency_price.try(:amount_in_word, CurrencyCourse::PRIMARY_CURRENCY),
      :memo => claim.memo,
      :memo_short => helpers.truncate(claim.memo, :length => 8),
      :memo_class => (!claim.memo_tasks_done and claim.memo != '') && 'red_back',
      :check_date => helpers.l( claim.check_date, :format => :default ),
      :check_date_class => helpers.check_date_status(claim),
      :docs_note => claim.docs_note,

      :applicant_id => claim.applicant.try(:id),
      :dependent_ids => claim.dependents.map(&:id).join(',')
    }

    if c.is_admin? or c.is_boss? or c.is_supervisor? # and c.current_company.offices.count > 1
      data.merge!({
        :office => claim.office.name,
        :office_short => helpers.truncate(claim.office.name, :length => 8)
      })
    end

    if c.can? :switch_view, c.current_user
      data.merge!({
        :approved_advance_tourist => helpers.approved_advance(claim, :tourist),
        :approved_advance_operator_prim => helpers.approved_advance(claim, :operator_prim),
        :approved_advance_operator => helpers.approved_advance(claim, :operator),
        :profit => claim.profit > 0 ? claim.profit.to_money : '',
        :profit_in_percent => claim.profit > 0 ? claim.profit_in_percent.to_percent : ''
      })
    end

    data
  end

  private

  def self.to_js_type(column_type)
    case column_type
    when :integer
      'INTEGER'
    when :float
      'REAL'
    when :text
      'TEXT'
    else
      'VARCHAR(255)'
    end
  end

  def assign_applicant(applicant_params)
    # Set address manually to avoid an exeption
    applicant_address = applicant_params[:address] if applicant_params[:address].present?
    applicant_params.delete :address

    if applicant_params[:id].blank?
      a = Tourist.new(applicant_params)
      a.company_id = company_id
      a.address.build_address(:company_id => company_id, :joint_address => applicant_address) if applicant_address
      a.save
      self.applicant = a
    else
      self.applicant = Tourist.where(:company_id => company_id).includes(:address).find(applicant_params[:id])
      if self.applicant.present?
        self.applicant.update_attributes(applicant_params)
        if applicant_address
          if self.applicant.address
            self.applicant.address.update_attributes({ :joint_address => applicant_address })
          else
            self.applicant.create_address({:company_id => company_id, :joint_address => applicant_address},:without_protection => true)
          end
        end
      end
    end
  end

  def assign_dependents(tourists)
    tourists.each do |key, tourist_hash|
      next if empty_tourist_hash?(tourist_hash)

      if tourist_hash[:id].blank?
        tourist = Tourist.new(tourist_hash)
        tourist.company_id = company_id
      else
        tourist = Tourist.where(:company_id => company_id).find(tourist_hash[:id])
        tourist.update_attributes(tourist_hash) if tourist.present?
      end

      tourist.company_id = company_id
      begin
        self.dependents << tourist
      rescue
        tourist.errors.full_messages.each { |msg| self.errors.add(:tourists, msg) }
      end
    end
  end

  def assign_payments_in(payments_in)
    payments_in.each do |key, payment_hash|
      next if empty_payment_hash?(payment_hash)

      payment_hash[:company_id] = company_id
      payment_hash[:recipient_id] = Company.first.try(:id)
      payment_hash[:recipient_type] = Company.first.class.try(:name)
      payment_hash[:payer_id] = self.applicant.try(:id)
      payment_hash[:payer_type] = self.applicant.class.try(:name)
      payment_hash[:currency] = CurrencyCourse::PRIMARY_CURRENCY
      payment_hash[:course] = 1

      process_payment_hash(payment_hash, self.payments_in)
    end
  end

  def assign_payments_out(payments_out)
    payments_out.each do |key, payment_hash|
      next if empty_payment_hash?(payment_hash)

      payment_hash[:company_id] = company_id
      payment_hash[:recipient_id] = self.operator.try(:id)
      payment_hash[:recipient_type] = self.operator.class.try(:name)
      payment_hash[:payer_id] = Company.first.try(:id)
      payment_hash[:payer_type] = Company.first.class.try(:name)
      payment_hash[:currency] = CurrencyCourse::PRIMARY_CURRENCY
      payment_hash[:reversed_course] = (payment_hash[:currency] == 'rur')

      process_payment_hash(payment_hash, self.payments_out)
    end
  end

  def update_debts
    self.operator_advance = self.payments_out.sum('amount_prim')
    # no sense here anymore
    self.approved_operator_advance = self.payments_out.where(:approved => true).sum('amount')
    self.approved_operator_advance_prim = self.payments_out.where(:approved => true).sum('amount_prim')

    self.operator_debt = self.operator_price.to_f - self.operator_advance.to_f
    self.operator_paid = create_paid_string(:out)

    self.tourist_advance = self.payments_in.sum('amount_prim')
    self.approved_tourist_advance = self.payments_in.where(:approved => true).sum('amount_prim')

    self.primary_currency_price = calculate_tour_price
    self.tourist_debt = self.primary_currency_price.to_f - self.tourist_advance.to_f
    self.tourist_paid = create_paid_string(:in)

    # profit amount available only full payment
    if approved_operator_advance_prim >= operator_price.to_f

      self.profit = primary_currency_price - approved_operator_advance

      self.profit_in_percent =
        begin
          perc = approved_operator_advance / 100
          perc > 0 ? profit/perc : 0
        rescue
          0
        end
    else
      self.profit = 0
      self.profit_in_percent = 0
    end
  end

  def check_not_null_fields
    Claim.columns.each do |col|
      if !col.null and self[col.name].nil? # Prevent null values in not null fields
        convertor = "to_#{col.type.to_s.first}".to_sym
        convertor = :to_s unless nil.respond_to?(convertor)
        self[col.name] = nil.send(convertor)
      end
    end
  end

  def calculate_tour_price

    sum_price = tour_price.to_f * course(tour_price_currency)
    sum_price += additional_services_price.to_f * course(additional_services_price_currency);

    # some fields are calculated per person
    fields =  ['visa_price', 'children_visa_price', 'insurance_price', 'additional_insurance_price', 'fuel_tax_price'];

    total = 0;
    fields.each do |f|
      count = send(f.sub(/_price$/, '_count'))
      total += send(f).to_f * count * course(send(f + '_currency')) if (count > 0)
    end
    (sum_price + total).round
  end

  def course(curr)
    case curr
    when 'eur'
      course_eur
    when 'usd'
      course_usd
    else
      1
    end
  end

  def create_paid_string(in_out)
    str = ''
    CurrencyCourse::CURRENCIES.each do |cur|
      payment_amount = (in_out == :in ? self.payments_in : self.payments_out).sum(:amount, :conditions => "currency = '#{cur}'")
      (str += cur.upcase << ': ' << sprintf("%0.0f", payment_amount) << ' ') unless payment_amount == 0.0
    end
    str.strip!
  end

  def remove_unused_payments
    Payment.where(:claim_id => nil, :company_id => company.id).destroy_all
  end

  def process_payment_hash(ph, in_out_payments)
    company.check_and_save_dropdown('form', ph[:form])
    if ph[:id].blank?
      payment = self.new_record? ? Payment.new(ph) : Payment.create(ph)
    else
      payment = Payment.find(ph[:id])
      payment.update_attributes(ph)
    end
    payment.company_id = company_id
    in_out_payments << payment
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
    lists = DropdownValue.available_lists.map{|k, v| k.to_s}
    lists.each do |l|
      company.check_and_save_dropdown(l, claim_params[l.to_sym])
    end
    company.check_and_save_dropdown('airport', claim_params[:airport_to])
    company.check_and_save_dropdown('airport', claim_params[:airport_back])

    if claim_params[:operator_id].blank?
      company.operators.create({ :name => claim_params[:operator] }) unless
        company.operators.find_by_name(claim_params[:operator])
      self.operator = company.operators.find_by_name(claim_params[:operator])
    else
      self.operator_id = claim_params[:operator_id]
    end

    company_cities = []

    if claim_params[:city_id].blank?
      unless claim_params[:city].blank?
        City.create({ :name => claim_params[:city] }) unless City.find_by_name(claim_params[:city])
        self.city = City.where(:name => claim_params[:city]).first
      end
    else
      self.city_id = claim_params[:city_id]
    end
    company_cities << self.city if self.city

    country_name = claim_params[:country][:name].strip
    unless country_name.blank?
      conds = ['(common = ? OR company_id = ?) AND name = ?', true, company_id, country_name]
      Country.create({
        :name => country_name,
        :company_id => company_id
      }) unless Country.where(conds).count > 0
      self.country = Country.where(conds).first
    end

    resort_name = claim_params[:resort][:name].strip
    unless resort_name.blank?
      conds = ['(common = ? OR company_id = ?) AND name = ? AND country_id = ?', true, company_id, resort_name, self.country.id]
      City.create({
        :name => resort_name,
        :country_id => self.country.id,
        :company_id => company_id
      }) unless City.where(conds).count > 0
      self.resort = City.where(conds).first
    end
    company_cities << self.resort if self.resort

    if !company_cities.empty?
      company_cities.each do |city|
        CityCompany.where(:company_id => company, :city_id => city).first_or_create
      end
    end
  end

  def presence_of_applicant
    self.errors.add(:applicant, I18n.t('activerecord.errors.messages.blank_or_wrong')) unless self.applicant.valid?
  end

  def primary_currency_price_in_word
    str = primary_currency_price.amount_in_words(CurrencyCourse::PRIMARY_CURRENCY)
    str.mb_chars.capitalize.to_s
  end

  def printable_fields
    {
      'Номер' => id,
      'Туроператор' => operator.try(:name),
      'ТуроператорНомер' => operator.try(:register_number),
      'ТуроператорСерия' => operator.try(:register_series),
      'ТуроператорИНН' => operator.try(:inn),
      'ТуроператорОГРН' => operator.try(:ogrn),
      'ТуроператорСайт' => operator.try(:site),
      'ТуроператорАдрес' => (operator.address.present? ? operator.address.pretty_full_address : ''),
      'ТуроператорФинОбеспечение' => operator.insurer_provision.present? ? operator.insurer_provision.gsub(/\d+/) { |sum| "#{sum} (#{RuPropisju.propisju(sum.to_i)})" } : '',
      'Страховщик' => operator.try(:insurer),
      'СтраховщикАдрес' => operator.try(:insurer_address),
      'ДоговорСтрахования' => operator.try(:insurer_contract),
      'ДоговорСтрахованияДата' => operator.insurer_contract_date.present? ? I18n.l(operator.insurer_contract_date, :format => :long) : '',
      'ДоговорСтрахованияДатаНач' => operator.insurer_contract_start.present? ? I18n.l(operator.insurer_contract_start, :format => :long) : '',
      'ДоговорСтрахованияДатаКон' => operator.insurer_contract_end.present? ? I18n.l(operator.insurer_contract_end, :format => :long) : '',
      'Город' => city.try(:name),
      'Страна' => country.try(:name),
      'Курорт' => resort.try(:name),
      'Отель' => hotel,
      'Размещение' => placement,
      'КоличествоТуристов' => (dependents.count + 1),
      'КоличествоНочей' => nights,
      'Переезд' => relocation,
      'Класс' => service_class,
      'Питание' => meals,
      'Виза' => (visa_count > 0 ? 'Да' : 'Нет'),
      'ВизаВзрослаяСум' => (visa_count > 0 ?
        (visa_count.to_s + 'x' + visa_price.round.to_s + ' ' + visa_price_currency) : 'Нет'),
      'ВизаДетскаяСум' => (children_visa_count > 0 ?
        (children_visa_count.to_s + 'x' + children_visa_price.round.to_s + ' ' + children_visa_price_currency) : 'Нет'),
      'СтраховкаМедицинская' => medical_insurance,
      'ТопливныйСборСум' => ((fuel_tax_count * fuel_tax_price) > 0 ?
         (fuel_tax_count.to_s + 'x' + fuel_tax_price.round.to_s + ' ' + fuel_tax_price_currency) : 'Нет'),
      'Трансфер' => transfer,
      'СтраховкаОтНевыезда' => (insurance_price > 0 ? 'Да' : 'Нет'),
      'СтраховкаОтНевыездаСум' => (insurance_price > 0 ?
        (insurance_count.to_s + 'x' + insurance_price.round.to_s + ' ' + insurance_price_currency) : 'Нет'),
      'СтраховкаДополнительнаяСум' => (additional_insurance_price > 0 ?
        (additional_insurance_count.to_s + 'x' + additional_insurance_price.round.to_s + ' ' + additional_insurance_price_currency) : 'Нет'),
      'ДополнительныеУслуги' => additional_services,
      'ДополнительныеУслугиСум' => additional_services_price > 0 ?
        (additional_services_price.round.to_s + ' ' + additional_services_price_currency) : '',
      'ДатаРезервирования' => (reservation_date.strftime('%d/%m/%Y') if reservation_date),
      'Сумма' => (primary_currency_price.to_money.to_s + ' руб'),
      'СуммаПрописью' => primary_currency_price_in_word,
      'СтоимостьТураВал' => tour_price.round.to_s + ' ' + tour_price_currency,
      'СуммаВал' => total_tour_price_in_curr.to_s + ' ' + tour_price_currency,
      'Компания' => company.try(:name),
      'Банк' => company.try(:bank),
      'БИК' => company.try(:bik),
      'РасчетныйСчет' => company.try(:curr_account),
      'КорреспондентскийСчет' => company.try(:corr_account),
      'ОГРН' => company.try(:ogrn),
      'ОКПО' => company.try(:okpo),
      'ИНН' => company.try(:inn),
      'АдресКомпании' => (company.address.present? ? company.address.pretty_full_address : ''),
      'ТелефонКомпании' => (company.address.phone_number if company.address.present?),
      'СайтКомпании' => company.try(:site),
      'ФИО' => applicant.try(:full_name),
      'Туристы' => dependents.map(&:full_name).unshift(applicant.try(:full_name)).map{|name| name.gsub ' ', '&nbsp;'}.compact.join(', '),
      'Адрес' => applicant.try(:address),
      'ТелефонТуриста' => applicant.try(:phone_number),
      'ДатаРождения' => applicant.try(:date_of_birth),
      'СерияПаспорта' => applicant.try(:passport_series),
      'НомерПаспорта' => applicant.try(:passport_number),
      'СрокПаспорта' => applicant.try(:passport_valid_until),
      'АэропортТуда' => airport_to,
      'АэропортОбратно' => airport_back,
      'РейсТуда' => flight_to,
      'РейсОбратно' => flight_back,
      'ВылетТуда' => depart_to,
      'ВылетОбратно' => depart_back,
      'ВремяВылетаТуда' => (depart_to.strftime('%H:%M') if depart_to),
      'ВремяВылетаОбратно' => (depart_back.strftime('%H:%M') if depart_back),
      'ПрибытиеТуда' => arrive_to,
      'ПрибытиеОбратно' => arrive_back,
      'ВремяПрибытияТуда' => (arrive_to.strftime('%H:%M') if arrive_to),
      'ВремяПрибытияОбратно' => (arrive_back.strftime('%H:%M') if arrive_back)
    }
  end

  def printable_collections
    {
      'Туристы' =>
        {
          :collection => dependents,
          'Турист.ФИО' => :full_name,
          'Турист.ДатаРождения' => :date_of_birth,
          'Турист.СерияПаспорта' => :passport_series,
          'Турист.НомерПаспорта' => :passport_number,
          'Турист.СрокПаспорта' => :passport_valid_until
        }
    }
  end

end

# == Schema Information
#
# Table name: claims
#
#  id                                  :integer          not null, primary key
#  user_id                             :integer
#  check_date                          :date
#  created_at                          :datetime
#  updated_at                          :datetime
#  office_id                           :integer
#  operator_id                         :integer
#  operator_confirmation               :string(255)
#  visa                                :string(255)      default("nothing_done"), not null
#  airport_to                          :string(255)
#  airport_back                        :string(255)
#  flight_to                           :string(255)
#  flight_back                         :string(255)
#  visa_check                          :date
#  tour_price                          :float            default(0.0)
#  visa_price                          :float            default(0.0)
#  insurance_price                     :float            default(0.0)
#  additional_insurance_price          :float            default(0.0)
#  fuel_tax_price                      :float            default(0.0)
#  primary_currency_price              :float            default(0.0)
#  course_usd                          :float            default(0.0)
#  tour_price_currency                 :string(255)      not null
#  airline                             :string(255)
#  visa_count                          :integer
#  meals                               :string(255)
#  placement                           :string(255)
#  nights                              :integer
#  hotel                               :string(255)
#  arrival_date                        :date
#  departure_date                      :date
#  early_reservation                   :boolean
#  docs_note                           :text
#  reservation_date                    :date
#  memo                                :text
#  country_id                          :integer
#  operator_price                      :float            default(0.0), not null
#  operator_debt                       :float            default(0.0), not null
#  tourist_debt                        :float            default(0.0), not null
#  depart_to                           :datetime
#  depart_back                         :datetime
#  maturity                            :date
#  visa_confirmation_flag              :boolean          default(FALSE)
#  resort_id                           :integer
#  city_id                             :integer
#  visa_price_currency                 :string(255)      default("eur"), not null
#  insurance_price_currency            :string(255)      default("eur"), not null
#  additional_insurance_price_currency :string(255)      default("eur"), not null
#  fuel_tax_price_currency             :string(255)      default("eur"), not null
#  calculation                         :text
#  course_eur                          :float            default(0.0)
#  tourist_advance                     :float            default(0.0), not null
#  tourist_paid                        :string(255)
#  operator_price_currency             :string(255)
#  closed                              :boolean          default(FALSE)
#  delta                               :boolean          default(TRUE)
#  operator_advance                    :float            default(0.0), not null
#  operator_paid                       :string(255)
#  profit                              :float            default(0.0), not null
#  profit_in_percent                   :float            default(0.0), not null
#  transfer                            :string(255)
#  relocation                          :string(255)
#  service_class                       :string(255)
#  additional_services                 :text
#  additional_services_price           :float            default(0.0), not null
#  additional_services_price_currency  :string(255)      default("eur"), not null
#  medical_insurance                   :string(255)
#  operator_maturity                   :date
#  approved_operator_advance           :float            default(0.0), not null
#  approved_tourist_advance            :float            default(0.0), not null
#  canceled                            :boolean          default(FALSE)
#  documents_status                    :string(255)      default("not_ready")
#  memo_tasks_done                     :boolean          default(FALSE)
#  operator_confirmation_flag          :boolean          default(FALSE)
#  insurance_count                     :integer
#  additional_insurance_count          :integer
#  fuel_tax_count                      :integer
#  children_visa_price                 :float            default(0.0), not null
#  children_visa_count                 :integer
#  children_visa_price_currency        :string(255)      default("eur"), not null
#  tourist_stat                        :string(255)
#  approved_operator_advance_prim      :float            default(0.0), not null
#  company_id                          :integer
#  arrive_to                           :datetime
#  arrive_back                         :datetime
#
