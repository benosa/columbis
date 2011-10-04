class Client < ActiveRecord::Base

  #validates :passport_series, :passport_number, :numericality => true
  #validates :passport_series, :length => { :is => 4 }
  #validates :passport_number, :length => { :is => 6 }
  validate :presence_of_fields

  def presence_of_fields
    errors.add(:base, "You should fill in at least one of fields") if [last_name, first_name, middle_name, passport_number, passport_series,  passport_valid_until, address, phone_number].join.size == 0
  end

  def full_name
    "#{last_name} #{first_name} #{middle_name}"
  end

end
