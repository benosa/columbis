class Item < ActiveRecord::Base
  attr_accessible :catalog_id, :notes_attributes
  belongs_to :catalog
  has_many :notes, :dependent => :destroy
  accepts_nested_attributes_for :notes
end
