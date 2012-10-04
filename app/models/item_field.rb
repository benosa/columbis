# -*- encoding : utf-8 -*-
class ItemField < ActiveRecord::Base
  attr_accessible :name, :catalog_id
  attr_protected :company_id

  belongs_to :company
  belongs_to :catalog
  has_many :notes, :dependent => :destroy

  validates_presence_of :name, :catalog_id
end
