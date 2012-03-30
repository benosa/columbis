class Company < ActiveRecord::Base
  attr_accessible :email, :country_id, :name, :offices_attributes, :printers_attributes,
                  :bank, :oficial_letter_signature, :bik, :curr_account, :corr_account, :ogrn, :city_ids
  attr_accessor :company_id

  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :payments_in, :as => :payer, :class_name => 'Payment'
  has_many :payments_out, :as => :recipient, :class_name => 'Payment'

  has_many :users
  has_many :offices
  has_many :city_companies
  has_many :cities, :through => :city_companies, :order => :name
  has_many :countries, :through => :cities, :group => 'countries.id', :order => :name

  has_many :printers, :order => :id

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :offices, :reject_if => proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :printers, :reject_if => proc { |attributes| attributes['template'].blank? }, :allow_destroy => true

  validates_presence_of :name

  def company_id
    id
  end

  def contract_printer
    printers.where(:mode => 'contract').last
  end

  def memo_printer_for(country)
    printers.where(:mode => 'memo', :country_id => country).last
  end

end
