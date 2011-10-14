class Company < ActiveRecord::Base
  has_one :address, :as => :addressable, :dependent => :destroy
  accepts_nested_attributes_for :address

  validates_presence_of :name
end
