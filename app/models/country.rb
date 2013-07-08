# -*- encoding : utf-8 -*-
class Country < ActiveRecord::Base
  attr_accessible :name, :company_id

  has_many :regions, :order => :name, :dependent => :nullify
  has_many :cities, :order => :name, :dependent => :nullify

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :company_id

  define_index do
    indexes :name, :sortable => true
    set_property :delta => true
  end

  sphinx_scope(:by_name) { { :order => :name } }
  default_sphinx_scope :by_name

  extend SearchAndSort
end
