class Item < ActiveRecord::Base
  belongs_to :catalog
  has_many :notes, :dependent => :destroy

  accepts_nested_attributes_for :notes
end
