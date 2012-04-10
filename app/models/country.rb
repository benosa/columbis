class Country < ActiveRecord::Base
  attr_accessible :name

  has_many :regions, :order => :name
  has_many :cities, :order => :name

  validates_presence_of :name
  validates_uniqueness_of :name
end
