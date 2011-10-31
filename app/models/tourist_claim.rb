class TouristClaim < ActiveRecord::Base
  attr_accessible :claim_id, :tourist_id
  belongs_to :claim
  belongs_to :tourist
end
