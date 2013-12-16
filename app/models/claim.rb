# -*- encoding : utf-8 -*-
class Claim < ActiveRecord::Base
  include Mistral::ClaimExtention # Special for Mistral company

  delegate :url_helpers, to: 'Rails.application.routes'

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
  attr_accessible :airport_back, :depart_to, :depart_back, :airline

  # marchroute block
  attr_accessible :meals, :placement, :nights, :hotel, :arrival_date, :departure_date,
                  :memo, :transfer, :relocation, :service_class, :additional_services, :medical_insurance

  # common
  attr_accessible :reservation_date, :visa, :visa_check, :visa_confirmation_flag, :check_date,
                  :operator_confirmation, :operator_confirmation_flag, :early_reservation, :documents_status,
                  :docs_note, :closed, :memo_tasks_done, :canceled, :tourist_stat, :assistant_id, :special_offer,
                  :contract_name

  # amounts and payments
  attr_accessible :operator_price, :operator_price_currency, :operator_debt, :tourist_debt,
                  :maturity, :tourist_advance, :tourist_paid, :operator_advance, :operator_paid,
                  :additional_services_price, :additional_services_currency, :operator_maturity,
                  :profit, :profit_in_percent, :approved_operator_advance, :approved_tourist_advance,
                  :bonus, :bonus_percent, :excluded_from_profit, :discount

  # nested attributes
  attr_accessible :applicant_attributes, :dependents_attributes,
                  :payments_in_attributes, :payments_out_attributes, :flights_attributes

  attr_accessor :claim_params # received params from controller

  belongs_to :company, :counter_cache => true
  belongs_to :user
  belongs_to :assistant, :class_name => 'User'
  belongs_to :office
  belongs_to :operator
  belongs_to :country
  belongs_to :city
  belongs_to :resort, :class_name => 'City'

  belongs_to :editor, :class_name => 'User', :foreign_key => 'locked_by'
  attr_accessor :current_editor

  has_one :tourist_claim, :dependent => :destroy, :conditions => { :applicant => true }
  has_one :applicant, :through => :tourist_claim, :source => :tourist

  has_many :tourist_claims, :dependent => :destroy, :conditions => { :applicant => false }
  has_many :dependents, :through => :tourist_claims, :source => :tourist

  has_many :payments_in, :class_name => 'Payment', :conditions => { :recipient_type => 'Company' }, :order => 'payments.id', :autosave => false
  has_many :payments_out, :class_name => 'Payment', :conditions => { :payer_type => 'Company' }, :order => 'payments.id', :autosave => false

  has_many :flights, :dependent => :destroy, :order => 'flights.created_at, flights.id'

  # accepts_nested_attributes_for :applicant, :reject_if => :empty_tourist_hash?
  # accepts_nested_attributes_for :dependents, :reject_if => :empty_tourist_hash?
  accepts_nested_attributes_for :payments_in, :reject_if => :empty_payment_hash?, :allow_destroy => true
  accepts_nested_attributes_for :payments_out, :reject_if => :empty_payment_hash?, :allow_destroy => true

  accepts_nested_attributes_for :flights, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :user_id, :office_id, :check_date, :arrival_date, :tourist_stat
  validates_presence_of :operator, :if => Proc.new { |claim| claim.payments_out && claim.payments_out.size > 0 }
  # validates_presence_of :user_id, :operator_id, :office_id, :country_id, :resort_id, :city_id
  # validates_presence_of :check_date, :tourist_stat, :arrival_date, :departure_date, :maturity,
  #                       :airport_back,
  #                       :tour_price, :hotel, :meals, :medical_insurance,
  #                       :placement, :transfer, :service_class, :relocation

  validates_presence_of :visa_check, :if => Proc.new { |claim| claim.visa_confirmation_flag }
  validates_presence_of :operator_confirmation, :if => Proc.new { |claim| claim.operator_confirmation_flag }
  validates_presence_of :operator_maturity, :if => Proc.new { |claim| claim.operator_price.to_f > 0 }

  [:tour_price_currency, :visa_price_currency, :insurance_price_currency, :additional_insurance_price_currency, :fuel_tax_price_currency, :operator_price_currency].each do |a|
    # validates_presence_of a
    validates_inclusion_of a, :in => CurrencyCourse::CURRENCIES
  end

  validate :presence_of_applicant
  validate :arrival_date_cant_be_greater_departure_date
  validate :check_operator_correctness
  validates :hotel, hotel: { message: proc{ I18n.t('activerecord.errors.messages.hotel_invalid') } }
  validates :num, :numericality => { :greater_than => 0 }, :uniqueness => { :scope => :company_id }, :if => proc{ |claim| claim.num.present? }
  validates_presence_of :num, :unless => :new_record?
  validate :check_lock, :on => :update

  before_validation :update_debts
  before_save :generate_num
  before_save :update_bonus
  before_save :update_active
  before_save :take_tour_duration
  before_save :set_flights_block

  scope :active, lambda { where(:active => true) }

  define_index do
    indexes :airport_back, :visa, :calculation, :documents_status, :docs_note, :meals, :placement,
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

    has :num
    has :company_id
    has :office_id
    has :user_id
    has :assistant_id

    has :reservation_date, :depart_to, :depart_back, :visa_check, :check_date,
        :arrival_date, :departure_date, :maturity, :operator_maturity, :type => :datetime
    has :operator_confirmation_flag, :active, :type => :boolean
    has :primary_currency_price, :tourist_advance, :tourist_debt, :operator_price, :operator_advance, :operator_debt,
        :approved_tourist_advance, :approved_operator_advance, :approved_operator_advance_prim,
        :profit, :profit_in_percent, :profit_acc, :profit_in_percent_acc,
        :bonus, :bonus_percent, :type => :float

    set_property :delta => true
  end

  local_data :extra_columns => :local_data_extra_columns, :extra_data => :local_extra_data,
            :columns_filter => :local_data_columns_filter,
            :scope => :local_data_scope

  extend SearchAndSort

  def assign_reflections_and_save(claim_params)
    self.claim_params = claim_params # save claims params
    self.transaction do
      check_dropdowns
      check_operator
      check_payments

      if self.valid? # trigger validations
        is_valid = !self.errors.any?
        # remove_unused_payments
        check_not_null_fields
        self.save
        check_validation_messages unless is_valid
        self.unlock if edited? && is_valid
      end
    end
  end

  def special_offer
    @special_offer ||= applicant.special_offer
  end

  def special_offer=(value)
    @special_offer = value
    applicant.special_offer = @special_offer if applicant
  end

  def applicant_attributes=(attributes)
    unless empty_tourist_hash?(attributes)
      id = attributes.delete('id')
      joint_address = attributes.delete('address')
      if id.blank?
        applicant = Tourist.new
        applicant.company = company
      else
        applicant = self.applicant || Tourist.where(id: id, company_id: company).first
      end
      applicant.assign_attributes(attributes)
      address = applicant.address || applicant.build_address(company_id: company_id)
      address.joint_address = joint_address if address
    else
      applicant = Tourist.new
      applicant.company = company
    end
    applicant.special_offer = @special_offer if applicant && !@special_offer.nil?
    applicant.save if applicant.new_record?
    self.applicant = applicant
  end

  def dependents_attributes=(attributes_hash)
    unless new_record?
      # first, create records in relation table for hash with presented id
      is_new_dependents = false
      attributes_hash.each_value do |attributes|
        next if empty_tourist_hash?(attributes)
        tourist_claim_id = attributes.delete('tourist_claim_id')
        if tourist_claim_id.present?
          tourist_claim = tourist_claims.select{ |tc| tc.id == tourist_claim_id.to_i }.first
          if tourist_claim and tourist_claim.tourist_id != attributes['id'].to_i
            tourist_claim.update_attributes(tourist_id: attributes['id'])
          end
        elsif attributes['id'].present? and !tourist_claims.select{ |tc| tc.tourist_id == attributes['id'].to_i }.first
          tourist_claims.create(tourist_id: attributes['id'])
          is_new_dependents = true
        end
      end
      dependents.reload if is_new_dependents
    end

    # update attributes for existing record, otherwise build new dependent
    attributes_hash.each do |i, attributes|
      next if empty_tourist_hash?(attributes)

      attributes.delete('tourist_claim_id') # special attribute for existing record
      destroy = attributes.delete('_destroy').to_boolean
      id = attributes.delete('id')
      if id.present?
        unless new_record?
          dependent = dependents.select{ |d| d.id == id.to_i }.first
          if !destroy and dependent
            dependent.validate_secondary_attributes = false
            dependent.assign_attributes(attributes)
            if dependent.valid?
              dependent.save
            else
              self.errors.add(:dependents, :invalid) unless errors.has_key?(:dependents)
            end
          else
            dependents.delete(dependent) if dependent
          end
        else
          dependent = Tourist.where(id: id, company_id: company).first
          if !destroy and dependent
            dependent.validate_secondary_attributes = false
            dependent.assign_attributes(attributes)
            dependent.company = company
            dependents << dependent
          end
        end
      elsif !destroy
        new_dependent = dependents.build(attributes)
        new_dependent.validate_secondary_attributes = false
        new_dependent.company = company
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

  def edited?
    editor.present? && Time.zone.now - locked_at < 30.minutes
  end

  def locked?
    edited? && editor != current_editor
  end

  def lock(user)
    self.editor, self.locked_at = user, Time.zone.now
    self.current_editor ||= user
    # Save locked_by and locked_at columns without any validations and update
    self.connection.execute "UPDATE claims SET locked_by=#{editor.id}, locked_at='#{locked_at.utc}' WHERE id=#{self.id}" rescue false
  end

  def unlock
    self.editor, self.locked_at = nil, nil
    self.connection.execute "UPDATE claims SET locked_by=NULL, locked_at=NULL WHERE id=#{self.id}" rescue false
  end

  def is_active?
    inactive = canceled?
    if not inactive
      inactive = closed? and operator_confirmation_flag? and !has_tourist_debt? and !has_operator_debt?
      inactive &&= visa == 'all_done' if visa_confirmation_flag?
      inactive &&= depart_to.to_date < Date.current if depart_to
    end
    not inactive
  end

  def fill_new
    self.applicant = Tourist.new
    self.payments_in.build(:currency => CurrencyCourse::PRIMARY_CURRENCY) if self.payments_in.empty?
    # Payments out might be created after save
    # self.payments_out.build(:currency => operator_price_currency || CurrencyCourse::PRIMARY_CURRENCY, :course => '') if self.payments_out.empty?
    today = Date.today

    # Temporarily disabled
    # self.course_usd = CurrencyCourse.where('currency = ? AND on_date <= ?', 'usd', today).order('on_date DESC, id DESC').first.try(:course)
    # self.course_eur = CurrencyCourse.where('currency = ? AND on_date <= ?', 'eur', today).order('on_date DESC, id DESC').first.try(:course)

    cur_attrs = Hash[[
      :tour_price_currency, :visa_price_currency, :children_visa_price_currency, :insurance_price_currency,
      :additional_insurance_price_currency, :fuel_tax_price_currency, :additional_services_price_currency,
      :operator_price_currency
    ].map{|c| [c, CurrencyCourse::PRIMARY_CURRENCY] }]
    self.attributes = cur_attrs

    self.reservation_date = today
    self.maturity = today + 3.days
  end

  def generate_num
    if company.present? && num.to_i == 0
      self.num = Claim.where(company_id: company_id).maximum(:num).to_i + 1
    end
  end

  def self.next_id
    Claim.last.try(:id).to_i + 1
  end

  def print_doc(mode)
    printer = company.send(:"#{mode}_printer")
    printer.prepare_template(printable_fields, printable_collections) if printer
  end

  # Define methods: print_contract, print_permit, print_warranty, print_act
  %w[contract permit warranty act].each do |mode|
    class_eval <<-EOS, __FILE__, __LINE__
      def print_#{mode}
        print_doc '#{mode}'
      end
    EOS
  end

  def print_memo
    printer = company.memo_printer_for(self.country_id)
    printer.prepare_template(printable_fields, printable_collections) if printer
  end

  def self.columns_info
    Claim.columns.sort!{ |x,y| x.name <=> y.name }.map{ |c| c.name + ' ' + to_js_type(c.type) }
  end

  def total_tour_price_in_curr
    course(tour_price_currency).round > 0 ? (calculate_tour_price / course(tour_price_currency)).round : 0
  end

  def update_bonus(_percent = nil)
    percent = _percent.nil? ? self.bonus_percent : BigDecimal.new(_percent)
    percent = 0 if percent.nan? or percent < 0
    bonus = profit_acc * percent / 100

    self.bonus = bonus
    self.bonus_percent = percent
  end

  def set_flights_block
    self.depart_to = flights.first.try(:depart)
    self.depart_back = flights.last.try(:depart)
    self.airport_back = flights.last.try(:airport_to)
    flights.each do |flight|
      flight.airline = airline
    end
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

  def check_lock
    errors.add(:base, I18n.t('claims.messages.is_editing')) if locked?
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

  def primary_currency_operator_price
    @primary_currency_operator_price ||= self.operator_price.to_f * (course(self.operator_price_currency) || 1)
  end

  def tour_price_with_discount
    @tour_price_with_discount ||= (discount.to_f > 0 ? tour_price.to_f * (1 - discount.to_f / 100) : tour_price.to_f).round
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

    def check_payments
      payments_in.each do |payment|
        payment.assign_attributes({
          :company => company,
          :recipient => company,
          :payer => applicant,
          :amount_prim => payment.amount, # tourist can pay only in primary currency (rur)
          :currency => CurrencyCourse::PRIMARY_CURRENCY,
          :course => 1,
          :canceled => canceled?
        }, :without_protection => true)
        payment.save
      end
      payments_out.each do |payment|
        payment.assign_attributes({
          :company => company,
          :recipient => operator,
          :payer => company,
          :reversed_course => false, #payment.currency == 'rur',
          :canceled => canceled?
        }, :without_protection => true)
        payment[:currency] = operator_price_currency if !payment.approved? || payment.currency.blank?
        payment.save
      end
    end

    def check_validation_messages
      # Remove message about payer and recipient of payments
      [:payer, :payer_id, :payer_type].each { |key| errors.delete(:"payments_in.#{key}") }
      [:recipient, :recipient_id, :recipient_type].each{ |key| errors.delete(:"payments_out.#{key}") }
    end

    def update_debts
      payments_in = self.payments_in.reject(&:marked_for_destruction?)
      approved_payments_in = payments_in.select(&:approved?)

      self.tourist_advance = payments_in.map(&:amount_prim).map(&:to_f).sum
      self.approved_tourist_advance = approved_payments_in.map(&:amount_prim).map(&:to_f).sum

      self.primary_currency_price = calculate_tour_price
      self.tourist_debt = self.primary_currency_price.to_f - self.tourist_advance.to_f

      payments_out = self.payments_out.reject(&:marked_for_destruction?)
      approved_payments_out = payments_out.select(&:approved?)

      self.operator_advance = payments_out.map(&:amount_prim).map(&:to_f).sum
      self.approved_operator_advance = approved_payments_out.map(&:amount).map(&:to_f).sum
      self.approved_operator_advance_prim = approved_payments_out.map(&:amount_prim).map(&:to_f).sum

      self.operator_debt = self.operator_price.to_f - self.operator_advance.to_f

      self.profit, self.profit_in_percent = calculate_profit
      self.profit_acc, self.profit_in_percent_acc = calculate_profit_acc
    end

    def update_active
      self.active = is_active?
      true
    end

    def check_not_null_fields
      Claim.columns.each do |col|
        if !col.null and self[col.name].nil? and col.name != 'id' # Prevent null values in not null fields
          convertor = "to_#{col.type.to_s.first}".to_sym
          convertor = :to_s unless nil.respond_to?(convertor)
          self[col.name] = nil.send(convertor)
        end
      end
    end

    def calculate_tour_price

      price = tour_price_with_discount
      sum_price = price * course(tour_price_currency)
      sum_price += additional_services_price.to_f * course(additional_services_price_currency);

      # some fields are calculated per person
      fields =  ['visa_price', 'children_visa_price', 'insurance_price', 'additional_insurance_price', 'fuel_tax_price'];

      total = 0;
      fields.each do |f|
        count = send(f.sub(/_price$/, '_count')) || 0
        total += send(f).to_f * count * course(send(f + '_currency')) if (count > 0)
      end
      (sum_price + total).round
    end

    # Profit for managment accounting
    def calculate_profit
      if primary_currency_operator_price > 1
        profit = primary_currency_price - primary_currency_operator_price
        profit_in_percent =
          begin
            primary_currency_price > 0 ? profit / primary_currency_price * 100 : 0
          rescue
            0
          end
      else
        profit = 0
        profit_in_percent = 0
      end
      [profit, profit_in_percent]
    end

    # Profit for accounting, it's available only after full payment
    def calculate_profit_acc
      if approved_operator_advance_prim > 0 && approved_operator_advance_prim >= operator_price.to_f

        profit_acc = primary_currency_price - approved_operator_advance

        profit_in_percent_acc =
          begin
            primary_currency_price > 0 ? profit_acc / primary_currency_price * 100 : 0
          rescue
            0
          end
      else
        profit_acc = 0
        profit_in_percent_acc = 0
      end
      [profit_acc, profit_in_percent_acc]
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

    # def create_paid_string(in_out)
    #   str = ''
    #   CurrencyCourse::CURRENCIES.each do |cur|
    #     payment_amount = (in_out == :in ? self.payments_in : self.payments_out).sum(:amount, :conditions => "currency = '#{cur}'")
    #     (str += cur.upcase << ': ' << sprintf("%0.0f", payment_amount) << ' ') unless payment_amount == 0.0
    #   end
    #   str.strip!
    # end

    # def remove_unused_payments
    #   Payment.where(:claim_id => nil, :company_id => company.id).destroy_all
    # end

    def process_payment_hash(ph, in_out_payments)
      company.check_and_save_dropdown('form', ph[:form])
      if ph[:id].blank?
        # self.new_record? ? in_out_payments.build(ph) : in_out_payments.create(ph)
        payment = in_out_payments.build(ph)
      else
        payment = in_out_payments.where(id: ph[:id].to_i).first
        payment.update_attributes(ph)
      end
      payment.company_id = company_id # to avoid mass-assignment issue
    end

    def empty_tourist_hash?(th)
      # th = th.symbolize_keys
      # th[:passport_number].blank? and th[:passport_valid_until].blank? and th[:id].blank? and
      # th[:passport_series].blank? and th[:full_name].blank? and th[:date_of_birth].blank?
      th[:full_name].blank? and th[:id].blank?
    end

    def empty_payment_hash?(ph)
      ph[:date_in].blank? and ph[:amount].to_f == 0.0 and ph[:id].blank?
    end

    def check_dropdowns
      DropdownValue.available_lists.keys.each do |l|
        company.check_and_save_dropdown(l.to_s, claim_params[l]) unless claim_params[l].nil?
      end
      company.check_and_save_dropdown('airport', claim_params[:airport_back])

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

      country_name = claim_params[:country][:name].strip rescue ''
      if country_name.present?
        conds = ['(common = ? OR company_id = ?) AND name = ?', true, company_id, country_name]
        Country.create({
          :name => country_name,
          :company_id => company_id
        }) unless Country.where(conds).count > 0
        self.country = Country.where(conds).first
        # self.country = Country.where(common: true, name: country_name).first
      end

      resort_name = claim_params[:resort][:name].strip rescue ''
      if !country.nil? && resort_name.present?
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

    def check_operator
      scoped = Operator.by_company_or_common(company)
      if claim_params[:operator_id].blank?
        scoped = scoped.where(name: claim_params[:operator])
      else
        scoped = scoped.where(id: claim_params[:operator_id])
      end
      self.operator = scoped.first
    end

    def presence_of_applicant
      unless applicant
        errors.add(:applicant, "#{I18n.t('activerecord.errors.messages.blank_or_wrong')}")
        return
      end

      if applicant.invalid? && applicant.errors[:full_name]
        errors.add(:applicant, "#{applicant.errors[:full_name].join}")
      end

      # TODO: It is temporary solution to avoid errors for old records
      validate_date = Date.parse('01.07.2013')
      if new_record? || reservation_date.nil? || reservation_date >= validate_date
        unless applicant.valid?
          applicant.errors.each do |atr, message|
            next if atr == :full_name
            errors.add(:applicant, "#{Tourist.human_attribute_name(atr)} #{message}")
          end
        end
        unless applicant.address && applicant.address.joint_address.present?
          applicant.errors.add(:address, I18n.t("errors.messages.blank"))
          errors.add(:applicant, "#{Tourist.human_attribute_name(:address)} #{I18n.t("errors.messages.blank")}")
        end
      end
      errors[:applicant].delete_if{ |msg| msg.blank? }
    end

    def arrival_date_cant_be_greater_departure_date
      if !arrival_date.nil? && !departure_date.nil? && (arrival_date > departure_date)
        errors.add(:departure_date, :cant_be_greater_departure_date)
      end
    end

    def check_operator_correctness
      operator_name = claim_params[:operator] rescue nil
      errors.add(:operator, :is_selected_from_existing) if operator.nil? && operator_name.present?
    end

    def check_country_correctness
      country_name = claim_params[:resort][:name].strip rescue nil
      errors.add(:country_id, :is_selected_from_existing) if country.nil? && country_name.present?
    end

    def take_tour_duration
      if (arrival_date != nil) && (departure_date != nil) && (departure_date >= arrival_date)
        self.tour_duration = (departure_date - arrival_date + 1)
      else
        self.tour_duration = 0
      end
    end

    def price_in_word(price, currency = CurrencyCourse::PRIMARY_CURRENCY)
      price.to_i.amount_in_words(currency).split(' ')[0...-1].join(' ')
    end

    def currency_in_word(price, currency = CurrencyCourse::PRIMARY_CURRENCY)
      price.to_i.amount_in_words(currency).split(' ')[-1]
    end

    def price_in_word_with_currency(price, currency)
      price.to_i.amount_in_words(currency)
    end

    def cut_price_currency(currency)
      I18n.t("cut_currency.#{currency}")
    end

    def tour_price_in_primary_currency
      (tour_price.to_f * course(tour_price_currency)).to_i
    end

    def printable_fields
      fields = {
        'Номер' => num,
        'НомерДоговора' => contract_name,
        'ДатаЗаездаС' => (arrival_date.strftime('%d/%m/%Y') if arrival_date),
        'ДатаЗаездаПо' => (departure_date.strftime('%d/%m/%Y') if departure_date),
        'Город' => city.try(:name),
        'Страна' => country.try(:name),
        'Курорт' => resort.try(:name),
        'Отель' => hotel,
        'Размещение' => placement,
        'КоличествоТуристов' => (dependents.count + 1),
        'КоличествоНочей' => nights,
        'КоличествоДней' => nights.to_i > 1 ? nights - 1 : nil ,
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
        'Сумма' => primary_currency_price.to_money.to_s,
        'Скидка' => discount.round(2).to_s + '%',
        'СуммаПрописью' => price_in_word(primary_currency_price),
        'СуммаВал' => total_tour_price_in_curr.to_s,
        'СуммаПрописьюВал' => price_in_word(total_tour_price_in_curr),
        'СтоимостьТура' => tour_price_in_primary_currency.to_s,
        'СтоимостьТураСкидка' => tour_price_with_discount.to_s,
        'СтоимостьТураПрописью' => price_in_word(tour_price_in_primary_currency),
        'СтоимостьТураСВал' => tour_price_in_primary_currency.to_s + ' ' + cut_price_currency(CurrencyCourse::PRIMARY_CURRENCY),
        'СтоимостьТураПрописьюСВал' => price_in_word_with_currency(tour_price_in_primary_currency, CurrencyCourse::PRIMARY_CURRENCY),
        'СтоимостьТураВал' => tour_price.round.to_s,
        'СтоимостьТураВалПрописью' => price_in_word(tour_price.round),
        'СтоимостьТураВалСВал' => tour_price.round.to_s + ' ' + cut_price_currency(tour_price_currency),
        'СтоимостьТураВалПрописьюСВал' => price_in_word_with_currency(tour_price.round, tour_price_currency),
        'Валюта' => currency_in_word(tour_price, tour_price_currency),
        'ВалютаСокр' => cut_price_currency(tour_price_currency),
        'КурсВалюты' => course(tour_price_currency),
        'СрокОплатыТуристом' => (maturity.strftime('%d/%m/%Y') if maturity),
        'Отправление' => arrival_date,
        'Возврат' => departure_date,
        'ФИОМенеджераИнициалы' => user.try(:initials_name),
        'НомерДоговора' => contract_name.present? ? contract_name : num
      }

      fields.merge!({
        'Компания' => company.try(:name),
        'Банк' => company.try(:bank),
        'БИК' => company.try(:bik),
        'РасчетныйСчет' => company.try(:curr_account),
        'КорреспондентскийСчет' => company.try(:corr_account),
        'ОГРН' => company.try(:ogrn),
        'ОКПО' => company.try(:okpo),
        'ИНН' => company.try(:inn),
        'КПП' => company.try(:kpp),
        'АдресКомпании' => (company.address.present? ? company.address.pretty_full_address : ''),
        'ТелефонКомпании' => (company.address.phone_number if company.address.present?),
        'СайтКомпании' => company.try(:site),
        'EmailКомпании' => company.try(:email),
        'Логотип' => company.logo_url(:thumb),
        'ФИОДериктораКомпании' => company.director,
        'ФИОДериктораКомпанииРод' => company.director_genitive,
        'ФИОДериктораКомпанииИниц' => initials(company.director),
        'ПолноеНазваниеКомпании' => company.try(:full_name) ? company.full_name : company.try(:name),
        'АдресКомпанииФакт' => company.try(:actual_address) ? company.actual_address :
          (company.address.present? ? company.address.pretty_full_address : '')
      }) if company

      fields.merge!({
        'ФИО' => applicant.try(:full_name),
        'ФИОИнициалы' => applicant.try(:initials_name),
        'ФИОАнгл' => applicant.try(:fio_latin),
        'Адрес' => applicant.try(:address).try(:joint_address),
        'ТелефонТуриста' => applicant.try(:phone_number),
        'ДатаРождения' => applicant.try(:date_of_birth),
        'СерияПаспорта' => applicant.try(:passport_series),
        'НомерПаспорта' => applicant.try(:passport_number),
        'СрокПаспорта' => applicant.try(:passport_valid_until),
        'ПаспортВыдан' => applicant.try(:passport_issued),
        'Обращение' => applicant.try(:sex) ? I18n.t("appeal_by_sex.#{applicant.sex}") : '',
        'Туристы' => dependents.map(&:full_name).unshift(applicant.try(:full_name)).map{|name| name.gsub ' ', '&nbsp;'}.compact.join(', ')
      }) if applicant

      fields.merge!({
        'Туроператор' => operator.try(:name),
        'ТуроператорПолноеНазвание' => operator.try(:full_name),
        'ТуроператорНомер' => operator.try(:register_number),
        'ТуроператорСерия' => operator.try(:register_series),
        'ТуроператорИНН' => operator.try(:inn),
        'ТуроператорОГРН' => operator.try(:ogrn),
        'ТуроператорКПП' => operator.try(:code_of_reason),
        'ТуроператорБанк' => operator.try(:banking_details),
        'ТуроператорСайт' => operator.try(:site),
        'ТуроператорТелефоны' => operator.try(:phone_numbers),
        'ТуроператорАдрес' => (operator.address.present? ? operator.address.pretty_full_address : ''),
        'ТуроператорАдресФакт' => operator.try(:actual_address) ? operator.actual_address :
          (operator.address.present? ? operator.address.pretty_full_address : ''),
        'ТуроператорФинОбеспечение' => operator.insurer_provision.present? ? operator.insurer_provision.to_s.gsub(/\d+/) { |sum| "#{sum} (#{sum.to_f.amount_in_words(CurrencyCourse::PRIMARY_CURRENCY)})" } : '',
        'Страховщик' => operator.try(:insurer),
        'СтраховщикПолноеНазвание' => operator.try(:insurer_full_name),
        'СтраховщикАдрес' => operator.try(:insurer_address),
        'СтраховщикАдресФакт' => operator.try(:actual_insurer_address) ? operator.actual_insurer_address :
          operator.try(:insurer_address),
        'ДоговорСтрахования' => operator.try(:insurer_contract),
        'ДоговорСтрахованияДата' => operator.insurer_contract_date.present? ? I18n.l(operator.insurer_contract_date, :format => :long) : '',
        'ДоговорСтрахованияДатаНач' => operator.insurer_contract_start.present? ? I18n.l(operator.insurer_contract_start, :format => :long) : '',
        'ДоговорСтрахованияДатаКон' => operator.insurer_contract_end.present? ? I18n.l(operator.insurer_contract_end, :format => :long) : ''
      }) if operator

      first_flight = flights.first if flights.length > 0
      last_flight = flights.last if flights.length > 1

      first_flight.instance_exec(fields) do |fields|
        fields.merge!({
          'ОтправлениеАэропортВылета' => airport_from,
          'ОтправлениеДатаВылета' => (depart.strftime('%d/%m/%Y') if depart),
          'ОтправлениеВремяВылета' => (depart.strftime('%H:%M') if depart),
          'ОтправлениеРейс' => flight_number,
          'ОтправлениеАэропортПрилета' => airport_to,
          'ОтправлениеДатаПрилета' => (arrive.strftime('%d/%m/%Y') if arrive),
          'ОтправлениеВремяПрилета' => (arrive.strftime('%H:%M') if arrive)
        })
      end if first_flight

      last_flight.instance_exec(fields) do |fields|
        fields.merge!({
          'ВозвратАэропортВылета' => airport_from,
          'ВозвратДатаВылета' => (depart.strftime('%d/%m/%Y') if depart),
          'ВозвратВремяВылета' => (depart.strftime('%H:%M') if depart),
          'ВозвратРейс' => flight_number,
          'ВозвратАэропортПрилета' => airport_to,
          'ВозвратДатаПрилета' => (arrive.strftime('%d/%m/%Y') if arrive),
          'ВозвратВремяПрилета' => (arrive.strftime('%H:%M') if arrive)
        })
      end if last_flight

      fields
    end

    def printable_collections
      {
        'Туристы' =>
          {
            :collection => dependents,
            'Турист.ФИО' => :full_name,
            'Турист.ФИОИнициалы' => :initials_name,
            'Турист.ФИОАнгл' => :fio_latin,
            'Турист.ДатаРождения' => :date_of_birth,
            'Турист.СерияПаспорта' => :passport_series,
            'Турист.НомерПаспорта' => :passport_number,
            'Турист.СрокПаспорта' => :passport_valid_until,
            'Турист.ПаспортВыдан' => :passport_issued
          }
      }
    end

    def initials(fio)
      init = ""
      i = fio.to_s.split(' ').each_with_index do |elem, i|
        if i == 0
          init += elem
        else
          init += (" " + elem[0] + ".")
        end
      end
      init
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
#  airport_back                        :string(255)
#  visa_check                          :date
#  tour_price                          :float            default(0.0)
#  visa_price                          :float            default(0.0)
#  insurance_price                     :float            default(0.0)
#  additional_insurance_price          :float            default(0.0)
#  fuel_tax_price                      :float            default(0.0)
#  primary_currency_price              :float            default(0.0)
#  course_usd                          :float            default(0.0)
#  tour_price_currency                 :string(255)      not null
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
