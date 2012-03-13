class Item < ActiveRecord::Base
  attr_protected :company_id
  belongs_to :company
  belongs_to :catalog
  has_many :notes, :dependent => :destroy

  accepts_nested_attributes_for :notes
end
