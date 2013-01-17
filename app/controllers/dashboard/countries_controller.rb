# -*- encoding : utf-8 -*-
class Dashboard::CountriesController < ApplicationController
  skip_before_filter :check_company_office, :only => [:get_regions, :get_cities]
  include CountriesHelper

  def get_regions
    @country         = Country.find(params[:country_id]) if params[:country_id]
    @regions_options = regions_for_select(@country)
    @cities_options  = !@regions_options.empty? ? cities_for_select(@regions_options.first[1]) : []
  end

  def get_cities
    @region          = Region.find(params[:region_id]) if params[:region_id]
    @cities_options  = cities_for_select(@region)
  end
end
