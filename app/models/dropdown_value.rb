class DropdownValue < ActiveRecord::Base
  attr_accessible :list, :value
  validates_presence_of :course, :currency, :on_date
end
