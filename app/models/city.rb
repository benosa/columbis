class City < ActiveRecord::Base
  belongs_to :country
  has_many :city_companies
  has_many :company, :through => :city_companies

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :region_id

  local_data :id, :name, :attributes => false, :scope => :local_data_scope

  def self.local_data_scope
    c = ApplicationController.current
    if c.can? :read, City
    	self.joins(:city_companies).where(:city_companies => { :company_id => c.current_company }).group('cities.id')
    else    
    	self.where("1 = 0")
    end    
  end

end
