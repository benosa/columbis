class Note < ActiveRecord::Base
  attr_accessible :value, :item_id, :item_field_id

  belongs_to :item
  belongs_to :item_field
end
