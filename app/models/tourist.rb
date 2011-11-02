class Tourist < ActiveRecord::Base
  attr_accessible :full_name, :passport_series, :passport_number,
                  :date_of_birth, :passport_valid_until, :phone_number, :address

  has_many :payments, :as => :payer
  has_many :refunds, :as => :recipient, :class_name => 'Payment'

  has_many :tourist_claims
  has_many :claims, :through => :tourist_claims

  validates_presence_of :first_name, :last_name, :middle_name
  validates_presence_of :passport_series, :passport_number
  validates_presence_of :date_of_birth, :passport_valid_until

  validates :passport_series, :passport_number, :numericality => true
  validates :passport_series, :length => { :is => 4 }
  validates :passport_number, :length => { :is => 6 }
  validates :passport_number, :presence => true, :uniqueness => {:scope => :passport_series}

  def first_last_name
    "#{first_name} #{last_name}".strip
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name}".strip
  end

  def full_name=(name)
    split = name.split(' ', 3)
    self.last_name = split[0]
    self.first_name = split[1]
    self.middle_name = split[2]
  end
end
