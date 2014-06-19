class TouristTask < ActiveRecord::Base
  attr_accessible :name, :state, :tourist_id, :user_id

  belongs_to :user
  belongs_to :tourist
end
