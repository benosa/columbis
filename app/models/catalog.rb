# -*- encoding : utf-8 -*-
class Catalog < ActiveRecord::Base
  attr_protected :company_id
  belongs_to :company

  has_many :items, :dependent => :destroy
  has_many :item_fields, :dependent => :destroy

  validates_presence_of :name
end
