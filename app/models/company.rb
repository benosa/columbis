class Company < ActiveRecord::Base
  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :payments_in, :as => :payer, :class_name => 'Payment'
  has_many :payments_out, :as => :recipient, :class_name => 'Payment'
  has_many :users

  accepts_nested_attributes_for :address

  validates_presence_of :name
end
