class Country < ActiveRecord::Base
  attr_accessible :name, :memo
  attr_protected :company_id
  belongs_to :company

  has_many :cities
  validates_presence_of :name
  validates_uniqueness_of :name

  acts_as_url :name, :url_attribute => :memo, :sync_url => true
end
