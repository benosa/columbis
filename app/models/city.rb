# -*- encoding : utf-8 -*-
class City < ActiveRecord::Base
  attr_accessible :name, :company_id, :country_id

  belongs_to :country
  has_many :city_companies
  has_many :company, :through => :city_companies

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:region_id, :company_id]

  local_data :id, :name, :attributes => false, :scope => :local_data_scope

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
