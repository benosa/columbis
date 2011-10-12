class ItemField < ActiveRecord::Base
  attr_accessible :name, :catalog_id

  belongs_to :catalog
  has_many :notes, :dependent => :destroy

  validates_presence_of :name, :catalog_id
end
