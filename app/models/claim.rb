class Claim < ActiveRecord::Base
  VISA_STATUSES = %w[nothing_done docs_got docs_sent visa_approved all_done].freeze
  DOCUMENTS_STATUSES = %w[not_ready received all_done].freeze

  # relations
  attr_protected :user_id, :company_id, :office_id, :operator_id, :resort_id, :city_id, :country_id

  # price block
  attr_accessible :tour_price, :tour_price_currency,
                  :visa_price, :visa_count, :visa_price_currency,
                  :children_visa_price, :children_visa_count, :children_visa_price_currency,
                  :insurance_price, :insurance_count, :insurance_price_currency,
                  :additional_insurance_price, :additional_insurance_count,  :additional_insurance_price_currency,
                  :fuel_tax_price, :fuel_tax_count, :fuel_tax_price_currency,
                  :primary_currency_price, :course_eur, :course_usd, :calculation

  # flight block
  attr_accessible :airline, :airport_to,  :airport_back, :flight_to, :flight_back, :depart_to, :depart_back

  # marchroute block
  attr_accessible :meals, :placement, :nights, :hotel, :arrival_date, :departure_date,
                  :memo, :transfer, :relocation, :service_class, :additional_services, :medical_insurance

  # common
  attr_accessible :reservation_date, :visa, :visa_check, :visa_confirmation_flag, :check_date,
                  :operator_confirmation, :operator_confirmation_flag, :early_reservation, :documents_status,
                  :docs_note, :closed, :memo_tasks_done, :canceled, :tourist_stat


  # amounts and payments
  attr_accessible :operator_price, :operator_price_currency, :operator_debt, :tourist_debt,
                  :maturity, :tourist_advance, :tourist_paid, :operator_advance, :operator_paid,
                  :additional_services_price, :additional_services_currency, :operator_maturity,
                  :profit, :profit_in_percent, :approved_operator_advance, :approved_tourist_advance

  belongs_to :company
  belongs_to :user
  belongs_to :office
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

  validates_presence_of :user_id, :operator_id, :office_id, :country_id, :resort_id, :city_id
  validates_presence_of :check_date, :tourist_stat, :arrival_date, :departure_date, :maturity,
                        :operator_maturity, :airline, :airport_to, :airport_back, :flight_to, :flight_back,
                        :hotel, :meals, :medical_insurance, :placement, :transfer, :service_class, :relocation

  [:tour_price_currency, :visa_price_currency, :insurance_price_currency, :additional_insurance_price_currency, :fuel_tax_price_currency, :operator_price_currency].each do |a|
    validates_presence_of a
    validates_inclusion_of a, :in => CurrencyCourse::CURRENCIES
  end

  validate :presence_of_applicant
  validate :correctness_of_maturity

  before_save :update_debts

  define_index do
    indexes airport_to, airport_back, flight_to, flight_back, meals, placement
    indexes hotel, memo, transfer, relocation, service_class, additional_services

    indexes applicant(:last_name), :as => :applicant_last_name, :sortable => true

    indexes user(:last_name), :as => :last_name, :sortable => true
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
    options.reverse_merge!(:filter => '', :column => 'id', :direction => 'asc')

    ids = search(options[:filter]).map{ |obj| obj.id if obj }

    opts = {}
    opts[:user_id] = options[:user_id] if options[:user_id]
    opts[:office_id] = options[:office_id] if options[:office_id]

    claims = where('claims.id in(?)', ids).where(opts)

    return claims if claims.empty?

    if options[:column] == 'applicant.last_name'
      claims.joins(:applicant).order('tourists.last_name ' + options[:direction])
    elsif %w[countries.name offices.name operators.name].include?(options[:column])
      claims.joins(options[:column].sub('.name', '').singularize.to_sym).order(options[:column] + ' ' + options[:direction])
    else
      claims.order(options[:column] + ' ' + options[:direction])
    end
  end

  def assign_reflections_and_save(claim_params)
    self.transaction do
      drop_reflections
      check_dropdowns(claim_params)

      assign_applicant(claim_params[:applicant])
      assign_dependents(claim_params[:dependents_attributes]) if claim_params.has_key?(:dependents_attributes)
      assign_payments(claim_params[:payments_in_attributes], claim_params[:payments_out_attributes]) unless self.new_record?

      unless self.errors.any?
        remove_unused_payments
        self.save
      end
    end
  end

  def documents_ready?
    self.documents_status == 'all_done'
  end

  def has_tourist_debt?
    self.tourist_debt != 0
  end

  def has_operator_debt?
    self.operator_debt != 0
  end

  def has_memo?
    !self.memo.blank?
  end

  def fill_new
    self.applicant = Tourist.new
    self.payments_in << Payment.new(:currency => CurrencyCourse::PRIMARY_CURRENCY)
    self.payments_out << Payment.new(:currency => CurrencyCourse::PRIMARY_CURRENCY)

    self.operator_price_currency = CurrencyCourse::PRIMARY_CURRENCY
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

  def self.columns_info
    Claim.columns.sort!{ |x,y| x.name <=> y.name }.map{ |c| c.name + ' ' + to_js_type(c.type) }
  end

  def total_tour_price_in_curr
    begin
      (calculate_tour_price / course(tour_price_currency)).round
    rescue
      0
    end
  end

  private

  def self.to_js_type(column_type)
    case column_type
    when :integer
      'INTEGER'
    when :float
      'REAL'
    else
      'TEXT'
    end
  end

  def assign_applicant(applicant_params)
    if applicant_params[:id].blank?
      a = Tourist.new(applicant_params)
      a.company_id = company_id
      a.save
      self.applicant = a
    else
      self.applicant = Tourist.find(applicant_params[:id])
    end
  end

  def assign_dependents(tourists)
    tourists.each do |key, tourist_hash|
      next if empty_tourist_hash?(tourist_hash)

      if tourist_hash[:id].blank?
        tourist = Tourist.new(tourist_hash)
        tourist.company_id = company_id
      else
        tourist = Tourist.find(tourist_hash[:id])
        tourist.update_attributes(tourist_hash)
      end

      tourist.company_id = company_id
      begin
        self.dependents << tourist
      rescue
        tourist.errors.full_messages.each { |msg| self.errors.add(:tourists, msg) }
      end
    end
  end

  def assign_payments(payments_in, payments_out)
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

    self.operator_debt = self.operator_price - self.operator_advance
    self.operator_paid = create_paid_string(:out)

    self.tourist_advance = self.payments_in.sum('amount_prim')
    self.approved_tourist_advance = self.payments_in.where(:approved => true).sum('amount_prim')

    self.primary_currency_price = calculate_tour_price
    self.tourist_debt = self.primary_currency_price - self.tourist_advance
    self.tourist_paid = create_paid_string(:in)

    # profit amount available only full payment
    if approved_operator_advance_prim >= operator_price

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

  def calculate_tour_price

    sum_price = tour_price * course(tour_price_currency)
    sum_price += additional_services_price * course(additional_services_price_currency);

    # some fields are calculated per person
    fields =  ['visa_price', 'children_visa_price', 'insurance_price', 'additional_insurance_price', 'fuel_tax_price'];

    total = 0;
    fields.each do |f|
      count = send(f.sub(/_price$/, '_count'))
      total += send(f) * count * course(send(f + '_currency')) if (count > 0)
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
      payment = Payment.create(ph)
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

    if claim_params[:country_id].blank?
      Country.create({ :name => claim_params[:country] }) unless
        (!claim_params[:country].blank? and Country.find_by_name(claim_params[:country]))
      self.country = Country.where( :name => claim_params[:country]).first
    else
      self.country_id = claim_params[:country_id]
    end

    if claim_params[:city_id].blank?
      unless claim_params[:city].blank?
        City.create({ :name => claim_params[:city] }) unless City.find_by_name(claim_params[:city])
        self.city = City.where( :name => claim_params[:city]).first
      end
    else
      self.city_id = claim_params[:city_id]
    end
    company.cities << self.city

    if claim_params[:resort_id].blank?
      unless claim_params[:resort].blank?
        City.create({ :name => claim_params[:resort], :country_id => self.country.id }) unless City.find_by_name(claim_params[:resort])
        self.resort = City.where( :name => claim_params[:resort]).first
      end
    else
      self.resort_id = claim_params[:resort_id]
    end
    company.cities << self.resort

    self.company.city_ids = self.company.city_ids.uniq
  end

  def presence_of_applicant
    self.errors.add(:applicant, I18n.t('activerecord.errors.messages.blank_or_wrong')) unless self.applicant.valid?
  end

  def correctness_of_maturity
    self.errors.add(:maturity, I18n.t('activerecord.errors.messages.blank_or_wrong')) unless self.applicant.valid?
  end

  def printable_fields
    {
      'Номер' => id,
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
      'СтраховкаМедицинская' => (insurance_price > 0 ? 'Да' : 'Нет'),
      'Трансфер' => transfer,
      'СтраховкаОтНевыезда' => (additional_insurance_price > 0 ? 'Да' : 'Нет'),
      'ДополнительныеУслуги' => additional_services,
      'ДатаРезервирования' => (reservation_date.strftime('%d/%m/%Y') if reservation_date),
      'Сумма' => (primary_currency_price.to_money.to_s + ' руб'),
      'СтоимостьТураВал' => tour_price.round.to_s + ' ' + tour_price_currency,
      'СуммаВал' => total_tour_price_in_curr.to_s + ' ' + tour_price_currency,
      'Компания' => company.try(:name),
      'Банк' => company.try(:bank),
      'БИК' => company.try(:bik),
      'РасчетныйСчет' => company.try(:curr_account),
      'КорреспондентскийСчет' => company.try(:corr_account),
      'ОГРН' => company.try(:ogrn),
      'Адрес' => (company.address.present? ? company.address.pretty_full_address : 'Нет адреса'),
      'Телефон' => (company.address.phone_number if company.address.present?),
      'ФИО' => applicant.try(:full_name),
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
      'ВремяВылетаОбратно' => (depart_back.strftime('%H:%M') if depart_back)
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
