# -*- encoding : utf-8 -*-
class Note < ActiveRecord::Base
  attr_accessible :value, :item_id, :item_field_id
  attr_protected :company_id

  belongs_to :company
  belongs_to :item
  belongs_to :item_field

  validates_presence_of :value
end
