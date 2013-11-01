# -*- encoding : utf-8 -*-
class Country < ActiveRecord::Base

  attr_accessible :name, :company_id, :common

  has_many :regions, :order => :name, :dependent => :nullify
  has_many :cities, :order => :name, :dependent => :nullify
  belongs_to :company

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :company_id

  define_index do
    indexes :name, :sortable => true
    has :common
    has :company_id

    set_property :delta => true
  end

  extend SearchAndSort
end
