class Dashboard::CountriesController < ApplicationController
  def get_regions
    @country = Country.find(params[:country_id]) if params[:country_id]
  end

  def get_cities
    @region = Region.find(params[:region_id]) if params[:region_id]
  end
end
