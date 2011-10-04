class Tourist < ActiveRecord::Base

  validates :passport_series, :passport_number, :numericality => true
  validates :passport_series, :length => { :is => 4 }
  validates :passport_number, :length => { :is => 6 }

  def fullname
    "#{last_name} #{first_name} #{middle_name}"
  end

end
