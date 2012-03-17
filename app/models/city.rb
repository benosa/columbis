class City < ActiveRecord::Base
  belongs_to :country
  has_many :city_companies
  has_many :company, :through => :city_companies
end
