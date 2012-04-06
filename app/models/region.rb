class Region < ActiveRecord::Base
  belongs_to :country
  has_many :cities, :order => :name
  validates_uniqueness_of :name, :scope => :country_id
end
