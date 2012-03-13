class Airline < ActiveRecord::Base
  attr_accessible :name
  attr_protected :company_id
  belongs_to :company
  validates_uniqueness_of :name
end
