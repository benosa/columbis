# -*- encoding : utf-8 -*-
module CountriesHelper

  def cities_for_select(region)
    region ? City.select([:id, :name]).where(:region_id => region).all.map{ |o| [o.name, o.id] } : []
  end

  def regions_for_select(country)
    country ? Region.select([:id, :name]).where(:country_id => country).all.map{ |o| [o.name, o.id] } : []
  end

  def availability_filter_options
  	Country::AVAILABILITIES.map{ |st| [ t("country_availabilities.#{st}"), st ] }
  end

end
