class Operator < ActiveRecord::Base
  attr_accessible :name

   has_many :payments, :as => :recipient
end
