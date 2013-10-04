# -*- encoding : utf-8 -*-
class Company < ActiveRecord::Base
  attr_accessible :email, :country_id, :name, :offices_attributes, :printers_attributes, :address_attributes,
                  :bank, :bik, :curr_account, :corr_account, :ogrn, :city_ids, :okpo,
                  :site, :inn, :time_zone, :subdomain, :logo, :director, :director_genitive,
                  :sms_signature, :sms_birthday_send
  mount_uploader :logo, LogoUploader

  attr_accessor :company_id

  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :payments_in, :as => :payer, :class_name => 'Payment', :dependent => :destroy
  has_many :payments_out, :as => :recipient, :class_name => 'Payment', :dependent => :destroy

  has_many :users, :dependent => :destroy, :order => 'Last_name ASC'
  has_many :offices, :dependent => :destroy, :order => 'name ASC'
  has_many :claims, :dependent => :destroy
  has_many :tourists, :dependent => :destroy
  has_many :operators, :dependent => :destroy, :order => 'name ASC'
  has_many :dropdown_values, :dependent => :destroy

  has_many :city_companies, :dependent => :destroy
  has_many :cities, :through => :city_companies, :order => :name, :uniq => true
  has_many :countries, :through => :cities, :group => 'countries.name, countries.id', :order => :name

  has_many :printers, :order => :id, :dependent => :destroy, inverse_of: :company

  accepts_nested_attributes_for :address, :reject_if => :all_blank
  accepts_nested_attributes_for :offices, :reject_if => proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :printers, :reject_if => :check_printers_attributes, :allow_destroy => true

  validates_presence_of :name
  validates :subdomain, presence: true, subdomain: true,
    length: { minimum: 3, maximum: 20 },
    format: { with: /\A[-a-z0-9]{3,20}\Z/, message: I18n.t('activerecord.errors.messages.subdomain_invalid') },
    uniqueness: { message: I18n.t('activerecord.errors.messages.subdomain_taken') }

  def company_id
    id
  end

  def find_or_create_printer(mode)
    printers.where(:mode => mode).reorder('id DESC').first_or_create
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

  private

    def check_printers_attributes(attributes)
      if attributes['id'].present?
        # Will not update template field if it is blank
        attributes.delete 'template' if attributes['template'].blank?
        false
      else
        attributes['template'].blank?
      end
    end
end
