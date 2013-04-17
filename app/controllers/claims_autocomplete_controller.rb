# -*- encoding : utf-8 -*-
class ClaimsAutocompleteController < ApplicationController

  before_filter { user_signed_in? }

  def tourist
    # tourists_arel = Tourist.accessible_by(current_ability)
    #   .select('tourists.*, addresses.joint_address')
    #   .where(["last_name ILIKE '%' || ? || '%'", params[:term]])
    #   .joins("LEFT JOIN addresses ON addresses.addressable_type = 'Tourist' AND addresses.addressable_id = tourists.id")
    #   .limit(100)
    # @tourists = Tourist.all_hashes tourists_arel
    terms = params[:term].split(' ')
    @tourists = Tourist.accessible_by(current_ability).includes(:address).limit(50)
    @tourists = @tourists.where(["last_name ILIKE '%' || ? || '%'", terms[0].strip]) if terms[0]
    @tourists = @tourists.where(["first_name ILIKE '%' || ? || '%'", terms[1].strip]) if terms[1]
    @tourists = @tourists.where(["middle_name ILIKE '%' || ? || '%'", terms[2].strip]) if terms[2]
    render 'claims/autocompletes/tourists'
  end

  def country
    @countries = Country.select([:id, :name])
      .where(["(common = ? OR company_id = ?) AND name ILIKE '%' || ? || '%'", true, current_company.id, params[:term]])
      .order('name ASC')
      .limit(50)
    render 'claims/autocompletes/countries'
  end

  def resort
    country_id = params[:country_id] || ''
    country_id = unless country_id.to_i > 0 # country_id is a string - name of country
      country_name = country_id.strip
      cond = ["(common = ? OR company_id = ?) AND name = ?", true, current_company.id, country_name]
      Country.where(cond).first.try(:id)
    end
    @resorts = City.select([:id, :name])
      .where(["country_id = ? AND (common = ? OR company_id = ?) AND name ILIKE '%' || ? || '%'", country_id, true, current_company.id, params[:term]])
      .order('name ASC')
      .limit(50)
    render 'claims/autocompletes/resorts'
  end

  def common
    @list = current_company.dropdown_for(params[:list])
    render 'claims/autocompletes/common_list'
  end

end