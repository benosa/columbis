class City < ActiveRecord::Base
  belongs_to :country
  has_many :city_companies
  has_many :company, :through => :city_companies

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :region_id
end
