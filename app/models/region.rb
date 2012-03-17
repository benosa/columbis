class Region < ActiveRecord::Base
  belongs_to :country
  has_many :cities, :order => :name
end
