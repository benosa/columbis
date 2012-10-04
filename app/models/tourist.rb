# -*- encoding : utf-8 -*-
class Tourist < ActiveRecord::Base
  attr_accessible :full_name, :passport_series, :passport_number, :first_name, :last_name,
                  :date_of_birth, :passport_valid_until, :phone_number, :address
  attr_protected :company_id

  belongs_to :company
  has_many :payments, :as => :payer

  has_many :tourist_claims
  has_many :claims, :through => :tourist_claims

  validates_presence_of :first_name, :last_name, :company_id

  local_data :full_name, :initials_name, :attributes => :all

  def first_last_name
    "#{first_name} #{last_name}".strip
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name if middle_name}".strip
  end

  def initials_name
    "#{last_name} #{first_name.initial}#{middle_name.initial if middle_name}".strip
  end

  def full_name=(name)
    split = name.split(' ', 3)
    self.last_name = split[0]
    self.first_name = split[1]
    self.middle_name = split[2] if split[2]
  end

  alias_method :name, :full_name

end
