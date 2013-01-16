# -*- encoding : utf-8 -*-
class Country < ActiveRecord::Base
  attr_accessible :name, :company_id

  has_many :regions, :order => :name
  has_many :cities, :order => :name

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :company_id
end
