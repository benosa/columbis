class Tourist < ActiveRecord::Base

  validates :pser, :pnum, :numericality => true
  validates :pser, :length => { :is => 4 }
  validates :pnum, :length => { :is => 6 }

  def fullname
    "#{lastname} #{firstname} #{middlename}"
  end

end
