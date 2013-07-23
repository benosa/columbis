class SmsTouristgroup < ActiveRecord::Base
  belongs_to :tourist
  belongs_to :sms_group
  
  attr_accessible :position, :sms_group_id, :tourist_id
end
