class StartTrip < ActiveRecord::Base
  attr_accessible :step, :user_id

  belongs_to :user
end
