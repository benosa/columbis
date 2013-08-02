class ClaimFlightsToFligths < ActiveRecord::Migration
  def up
    Claim.select([:id, :airline, :airport_to, :airport_back, :flight_to,
      :flight_back, :depart_to, :depart_back, :arrive_to, :arrive_back])
    .find_each(:batch_size => 500) do |claim|
      Flight.new(:airline => claim.airline, :airport_from => nil,
        :airport_to => claim.airport_to, :flight_number => claim.flight_to,
        :depart => claim.depart_to, :arrive => claim.arrive_to,
        :claim_id => claim.id).save
      Flight.new(:airline => claim.airline, :airport_from => nil,
        :airport_to => claim.airport_back, :flight_number => claim.flight_back,
        :depart => claim.depart_back, :arrive => claim.arrive_back,
        :claim_id => claim.id).save
    end

    remove_column :claims, :airport_to
    remove_column :claims, :flight_to
    remove_column :claims, :flight_back
    remove_column :claims, :arrive_to
    remove_column :claims, :arrive_back
  end

  def down
    add_column :claims, :airport_to, :string
    add_column :claims, :flight_to, :string
    add_column :claims, :flight_back, :string
    add_column :claims, :arrive_to, :datetime
    add_column :claims, :arrive_back, :datetime

    Claim.reset_column_information

    Claim.select([:id, :airline, :airport_to, :airport_back, :flight_to,
      :flight_back, :depart_to, :depart_back, :arrive_to, :arrive_back])
    .find_each(:batch_size => 500) do |claim|
      flights = Flight.where(:claim_id => claim.id).order("depart ASC")
      to = flights.first
      back = flights.last
      if to
        claim.update_column(:airline, to.airline)
        claim.update_column(:airport_to, to.airport_to)
        claim.update_column(:flight_to, to.flight_number)
        claim.update_column(:depart_to, to.depart)
        claim.update_column(:arrive_to, to.arrive)
      end
      if back
        claim.update_column(:airport_back, back.airport_to)
        claim.update_column(:flight_back, back.flight_number)      
        claim.update_column(:depart_back, back.depart)      
        claim.update_column(:arrive_back, back.arrive)
      end
    end
  end
end
