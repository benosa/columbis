class TouristComments < ActiveRecord::Base
  attr_accessible :body, :tourist_id, :user_id

  belongs_to :user
  belongs_to :tourist
end
