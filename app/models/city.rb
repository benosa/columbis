class City < ActiveRecord::Base
  attr_accessible :name, :country_id
  attr_protected :company_id
  belongs_to :company
  belongs_to :country

  validates_presence_of :name
end
