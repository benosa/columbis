class Flight < ActiveRecord::Base
  attr_accessible :airline, :airport_from, :airport_to, :arrive, :depart, :flight_number, :claim_id

  belongs_to :claim
end
