class Catalog < ActiveRecord::Base
  has_many :items, :dependent => :destroy
  has_many :item_fields, :dependent => :destroy

  validates_presence_of :name
end
