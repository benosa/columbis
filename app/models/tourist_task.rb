class TouristTask < ActiveRecord::Base
  attr_accessible :name, :state, :tourist_id, :user_id
  validates_length_of :name, :maximum => 255

  belongs_to :user
  belongs_to :tourist
end
