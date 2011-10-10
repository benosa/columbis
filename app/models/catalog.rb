class Catalog < ActiveRecord::Base
  validates_presence_of :name
  has_many :items, :dependent => :destroy
  has_many :item_fields, :dependent => :destroy
end
