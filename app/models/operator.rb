class Operator < ActiveRecord::Base
  attr_accessible :name, :register_number, :register_series, :inn, :ogrn, :site,
  				  :insurer, :insurer_address, :insurer_provision, :insurer_contract,
  				  :insurer_contract_date, :insurer_contract_start, :insurer_contract_end,
  				  :address_attributes

  attr_protected :company_id

  belongs_to :company
  has_many :payments, :as => :recipient
  has_one :address, :as => :addressable, :dependent => :destroy

  accepts_nested_attributes_for :address

  validates_presence_of :name
  validates_uniqueness_of :name
end
