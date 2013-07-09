class CountriesController < ApplicationController
  load_and_authorize_resource

  def index
    @countries =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Country))
        set_filter_to options
        search_paginate( Country.search_and_sort(options), options)
      else
        Country.accessible_by(current_ability).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def show
    @country = Country.where(:id => params[:id]).first
  end

  def new
  end

  def create
    if @country.save(params[:country])
      redirect_to countries_path, :notice => t('countries.messages.created')
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @country.save(params[:country])
      redirect_to countries_path, :notice => t('countries.messages.updated')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @country.destroy
    redirect_to countries_path, :notice => t('countries.messages.destroyed')
  end

  private
    def set_filter_to(options)
      case params[:availability]
        when 'own'
          options[:with][:common] = false
          options[:with][:company_id] = current_company.id
        when 'open'
          options[:sphinx_select] = "*, IF(company_id <> #{current_company.id}, 1, 0) AS company"
          options[:with][:company] = 1
          options[:with][:common] = true
          options[:with].delete(:company_id)
        else
          unless current_user.role == "admin"
            options[:sphinx_select] = "*, IF(common = 1.0 OR company_id = #{current_company.id}, 1, 0) AS company"
            options[:with]['company'] = 1
            options[:with].delete(:company_id)
            options[:with].delete(:common)
          end
      end
    end
end