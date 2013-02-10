# -*- encoding : utf-8 -*-
class Operator < ActiveRecord::Base
  attr_accessible :name, :register_number, :register_series, :inn, :ogrn, :site,
  				  :insurer, :insurer_address, :insurer_provision, :insurer_contract,
  				  :insurer_contract_date, :insurer_contract_start, :insurer_contract_end,
  				  :address_attributes

  attr_protected :company_id

  belongs_to :company
  has_many :claims, :inverse_of => :operator
  has_many :payments, :as => :recipient
  has_one :address, :as => :addressable, :dependent => :destroy

  accepts_nested_attributes_for :address, :reject_if => :all_blank

  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope :order => :name

  define_index do
    indexes :name, :register_number, :register_series, :inn, :ogrn, :sortable => true
    indexes address(:joint_address), :as => :joint_address, :sortable => true
    has :company_id
    set_property :delta => true
  end

  sphinx_scope(:by_name) { { :order => :name } }
  default_sphinx_scope :by_name

  local_data :extra_columns => :local_data_extra_columns, :extra_data => :local_extra_data

  extend SearchAndSort

  def self.local_data_extra_columns
    [ :address, :address_id ]
  end

  def local_extra_data
    {
      :address => self.address.try(:pretty_full_address),
      :address_id => self.address.try(:id),
    }
  end

end
