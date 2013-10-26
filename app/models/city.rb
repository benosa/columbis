# -*- encoding : utf-8 -*-
class City < ActiveRecord::Base
  attr_accessible :name, :company_id, :country_id

  belongs_to :country
  belongs_to :company
  has_many :city_companies
  #has_many :company, :through => :city_companies

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:region_id, :company_id]

  scope :with_country_columns, ->(apply_includes = false) do
    country_columns = Country.columns.map{ |col| "countries.#{col.name} as country_#{col.name}" }
    scope = joins("LEFT JOIN countries ON countries.id = cities.country_id")
      .select(['cities.*'] + country_columns)
  end

  define_index do
    indexes :name, :sortable => true
    indexes country(:name), :as => :country_name, :sortable => true

    has :common
    has :company_id

    set_property :delta => true
  end

  local_data :id, :name, :attributes => false, :scope => :local_data_scope

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

  def save_with_dropdown_lists(company, params)
    self.save(with_country_name(company, params))
  end

  def update_with_dropdown_lists(company, params)
    self.update_attributes(with_country_name(company, params))
  end

  private
    def with_country_name(company, params)
      country_name = params[:country][:name].strip rescue ''
      unless country_name.blank?
        conds = ['(common = ? OR company_id = ?) AND name = ?', true, company, country_name]
        Country.create({
          :name => country_name,
          :company_id => company.id
        }) unless Country.where(conds).count > 0
        self.country_id = Country.where(conds).first.id
      end
      params
    end
end
