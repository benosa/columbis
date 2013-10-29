# -*- encoding : utf-8 -*-
class Company < ActiveRecord::Base
  attr_accessible :email, :country_id, :name, :offices_attributes, :printers_attributes, :address_attributes,
                  :bank, :bik, :curr_account, :corr_account, :ogrn, :city_ids, :okpo,
                  :site, :inn, :time_zone, :subdomain, :logo, :director, :director_genitive,
                  :sms_signature, :sms_birthday_send, :owner, :user_payment_id, :tariff_end,
                  :tariff_id
  mount_uploader :logo, LogoUploader

  attr_accessor :company_id

  belongs_to :owner, :class_name => 'User', :inverse_of => :company
  belongs_to :tariff, :class_name => 'TariffPlan'
  belongs_to :user_payment

  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :payments_in, :as => :payer, :class_name => 'Payment', :dependent => :destroy
  has_many :payments_out, :as => :recipient, :class_name => 'Payment', :dependent => :destroy

  has_many :users, :dependent => :destroy, :order => 'Last_name ASC'
  has_many :offices, :dependent => :destroy, :order => 'name ASC'
  has_many :claims, :dependent => :destroy
  has_many :user_payments, :dependent => :destroy
  has_many :tourists, :dependent => :destroy
  has_many :operators, :dependent => :destroy, :order => 'name ASC'
  has_many :dropdown_values, :dependent => :destroy

  has_many :city_companies, :dependent => :destroy
  has_many :cities, :through => :city_companies, :order => :name, :uniq => true
  has_many :countries, :through => :cities, :group => 'countries.name, countries.id', :order => :name

  has_many :printers, :order => :id, :dependent => :destroy, inverse_of: :company

  validates_presence_of :name, :tariff_id, :tariff_end
  validates :subdomain, presence: true, subdomain: true,
    length: { minimum: 3, maximum: 20 },
    format: { with: /\A[-a-z0-9]{3,20}\Z/, message: I18n.t('activerecord.errors.messages.subdomain_invalid') },
    uniqueness: { message: I18n.t('activerecord.errors.messages.subdomain_taken') }
  validates :logo, :file_size => { :maximum => CONFIG[:max_logo_size].megabytes.to_i }

  accepts_nested_attributes_for :address, :reject_if => :all_blank
  accepts_nested_attributes_for :offices, :reject_if => :check_offices_attributes, :allow_destroy => true
  accepts_nested_attributes_for :printers, :reject_if => :check_printers_attributes, :allow_destroy => true

  before_create :set_tariff_plan
  after_create do |company|
    Mailer.company_was_created(self).deliver
  end

  extend SearchAndSort

  define_index do
    indexes subdomain, :name, sortable: true
    indexes owner(:phone), as: :phone, sortable: true
    indexes owner(:email), as: :email, sortable: true
    indexes [owner.last_name, owner.first_name, owner.middle_name], :as => :owner, :sortable => true

    has :offices_count, :users_count, :claims_count, :tourists_count, :tasks_count
    has :created_at, type: :datetime
  end

  def company_id
    id
  end

  def find_or_create_printer(mode)
    printer = printers.where(:mode => mode).reorder('id DESC').first_or_create
    printer_file(printer)
    printer
  end

  # Define methods: contract_printer, permit_printer, warranty_printer, act_printer
  %w[contract permit warranty act].each do |mode|
    class_eval <<-EOS, __FILE__, __LINE__
      def #{mode}_printer
        find_or_create_printer('#{mode}')
      end
    EOS
  end

  def memo_printer_for(country_id)
    printer = printers.where(:mode => 'memo', :country_id => country_id).last
    unless printer
      country = Country.where(:id => country_id).last
      if country
        printer = printers.build(:mode => 'memo')
        printer.country = country
        printer.save
      end
    end
    printer_file(printer)
    printer
  end

  def check_and_save_dropdown(list, value)
    DropdownValue.check_and_save(list, value, id)
  end

  def dropdown_for(list)
    DropdownValue.dd_for(list, id)
  end

  def dropdown_values_for(list)
    DropdownValue.values_for(list, id)
  end

  def self.update_by_default_tariff(companies)
    default_id = TariffPlan.default.id
    companies.each do |company|
      company.update_column(:tariff_id, default_id)
      company.update_column(:tariff_end, Time.zone.now + CONFIG[:days_for_default_tariff].days)      
    end
  end

  def tariff_payd(payment)
    self.user_payment = payment
    if self.tariff == payment.tariff
      self.tariff_end = self.tariff_end + payment.period.months
    else
      self.tariff = payment.tariff
      self.tariff_end = Time.zone.now + payment.period.months
    end
    self.save
  end

  private

    def set_tariff_plan
      self.tariff_id = TariffPlan.default.id
      self.tariff_end = Time.zone.now + CONFIG[:days_for_default_tariff].days
    end

    def check_offices_attributes(attributes)
      offices.count < offices.length && attributes['id'].blank? && attributes['name'].blank?
    end

    def check_printers_attributes(attributes)
      if attributes['id'].present?
        # Will not update template field if it is blank
        attributes.delete 'template' if attributes['template'].blank?
        false
      else
        attributes['template'].blank?
      end
    end

    def printer_file(printer)
      from = Rails.root.to_s + "/app/views/printers/default_forms/ru/"
      if printer && printer.try(:template).blank?
        file_name = printer.mode
        if printer.mode == 'memo'
          if File.exist?(from + "memo_#{printer.country.name}.html")
            file_name += "_#{printer.country.name}"
          end
        end
        file_name += ".html"
        from += file_name
        if File.exist?(from)
          printer.template = File.open(from)
          printer.save!
        end
      end
    end
end
