class Operator < ActiveRecord::Base
  attr_accessible :name
  attr_protected :company_id

  belongs_to :company
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :payments, :as => :recipient
end
