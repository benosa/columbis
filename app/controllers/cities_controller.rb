# -*- encoding : utf-8 -*-
class CitiesController < ApplicationController
  load_and_authorize_resource

  def index
    @cities =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, City))
        search_paginate(City.search_and_sort(options).includes(:country), options)
      else
        City.accessible_by(current_ability).includes(:country).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def show
    @city = City.where(:id => params[:id]).first
  end

  def new
  end

  def create
    if @city.save_with_dropdown_lists(params[:city])
      redirect_to cities_path, :notice => t('cities.messages.created')
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @city.save_with_dropdown_lists(params[:city])
      redirect_to cities_path, :notice => t('cities.messages.updated')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @city.destroy
    redirect_to cities_path, :notice => t('cities.messages.destroyed')
  end
end