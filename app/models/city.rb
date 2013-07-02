# -*- encoding : utf-8 -*-
class City < ActiveRecord::Base
  attr_accessible :name, :company_id, :country_id

  belongs_to :country
  belongs_to :company
  has_many :city_companies
  #has_many :company, :through => :city_companies

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:region_id, :company_id]

  default_scope :order => :name

  define_index do
    indexes :name, :sortable => true
    indexes country.name, as: :country_name, :sortable => true 
    set_property :delta => true
  end

  local_data :id, :name, :attributes => false, :scope => :local_data_scope

  sphinx_scope(:by_name) { { :order => :name } }
  default_sphinx_scope :by_name

  extend SearchAndSort

  def self.local_data_scope
    c = ApplicationController.current
    if c.can? :read, City
    	self.joins(:city_companies).where(:city_companies => { :company_id => c.current_company }) \
          .select('cities.id, cities.name').group('cities.id, cities.name')
    else
    	self.where("1 = 0")
    end
  end

end
