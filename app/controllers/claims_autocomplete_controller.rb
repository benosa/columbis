# -*- encoding : utf-8 -*-
class ClaimsAutocompleteController < ApplicationController
  include ClaimsHelper

  before_filter :check_user

  def tourist
    # tourists_arel = Tourist.accessible_by(current_ability)
    #   .select('tourists.*, addresses.joint_address')
    #   .where(["last_name ILIKE '%' || ? || '%'", params[:term]])
    #   .joins("LEFT JOIN addresses ON addresses.addressable_type = 'Tourist' AND addresses.addressable_id = tourists.id")
    #   .limit(100)
    # @tourists = Tourist.all_hashes tourists_arel
    terms = params[:term].split(' ')
    @tourists = Tourist.accessible_by(current_ability).where(company_id: current_company.id).includes(:address).limit(50)
    @tourists = @tourists.where(["last_name ILIKE '%' || ? || '%'", terms[0].strip]) if terms[0]
    @tourists = @tourists.where(["first_name ILIKE '%' || ? || '%'", terms[1].strip]) if terms[1]
    @tourists = @tourists.where(["middle_name ILIKE '%' || ? || '%'", terms[2].strip]) if terms[2]
    render 'claims/autocompletes/tourists'
  end

  def city
    @list = current_company.cities.select('cities.id, cities.name')
      .where(["cities.name ILIKE '%' || ? || '%'", params[:term]])
      .limit(50)
    render 'claims/autocompletes/list'
  end

  def operator
    unless is_mistral?
      @list = Operator.select('operators.id, operators.name')
        .where(["(common = ? OR company_id = ?) AND operators.name ILIKE '%' || ? || '%'", true, current_company.id, params[:term]])
        .order('common ASC, name ASC')
        .limit(50)
    else
      # Special conditions for Mistral
      @list = mistral_operator_list(current_user, params[:term])
    end

    render 'claims/autocompletes/list'
  end

  def country
    @list = Country.select([:id, :name])
      .where(["(common = ? OR company_id = ?) AND name ILIKE '%' || ? || '%'", true, current_company.id, params[:term]])
      .order('name ASC')
      .limit(50)
    render 'claims/autocompletes/list'
  end

  def resort
    country_id = params[:country_id] || ''
    unless country_id.to_i > 0 # country_id is a string - name of country
      country_name = country_id.strip
      cond = ["(common = ? OR company_id = ?) AND name = ?", true, current_company.id, country_name]
      country_id = Country.where(cond).first.try(:id)
    end
    @list = City.select([:id, :name])
      .where(["country_id = ? AND (common = ? OR company_id = ?) AND name ILIKE '%' || ? || '%'", country_id, true, current_company.id, params[:term]])
      .order('name ASC')
      .limit(50)
    render 'claims/autocompletes/list'
  end

  def dropdown
    @list = current_company.dropdown_for(params[:list]).select(:value)
      .where(["value ILIKE '%' || ? || '%'", params[:term]])
      .reorder('value ASC')
      .group(:value)
      .limit(50)
    render 'claims/autocompletes/dropdown_list'
  end

  private

    def check_user
      unless user_signed_in?
        render text: '' if request.xhr?
        redirect_to root_path unless request.xhr?
      end
    end

    def render(*args)
      options = args.extract_options!
      options.merge! formats: :json
      super *(args << options)
    end

end