class CountriesController < ApplicationController
  load_and_authorize_resource

  def index
    @countries =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Country))
        search_paginate(Country.search_and_sort(options), options)
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
end