class Tourist < ActiveRecord::Base

  validates :name, :length => { :maximum => 70 }
  validates :pser, :pnum, :numericality => true
  validates :pser, :length => { :is => 4 }
  validates :pnum, :length => { :is => 6 }

end
