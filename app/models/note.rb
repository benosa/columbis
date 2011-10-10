class Note < ActiveRecord::Base
  belongs_to :item
  belongs_to :item_field
end
