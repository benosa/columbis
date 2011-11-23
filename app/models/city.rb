class City < ActiveRecord::Base
  attr_accessible :name, :country_id
  belongs_to :country

  validates_presence_of :name
end
