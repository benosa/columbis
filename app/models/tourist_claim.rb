# -*- encoding : utf-8 -*-
class TouristClaim < ActiveRecord::Base
  attr_accessible :claim_id, :tourist_id, :applicant
  belongs_to :claim
  belongs_to :tourist
end
