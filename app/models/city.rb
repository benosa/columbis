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
    indexes country(:name), :as => :country, :sortable => true
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

  def save_with_dropdown_lists(params)
    c = ApplicationController.current
    company_id = c.current_company
    country_name = params[:country][:name].strip rescue ''
    unless country_name.blank?
      conds = ['(common = ? OR company_id = ?) AND name = ?', true, company_id, country_name]
      Country.create({
        :name => country_name,
        :company_id => company_id
      }) unless Country.where(conds).count > 0
      self.country = Country.where(conds).first
    end

    unless self.errors.any?
      self.save
    else
      false
    end
  end
end
