# -*- encoding : utf-8 -*-
class CitiesController < ApplicationController
  load_and_authorize_resource

  def index
    @cities =
      if search_or_sort?
        options = { with_current_abilities: true }
        options.merge!(order: "common asc, #{sort_col} #{sort_dir}", sort_mode: :extended)
        options = search_and_sort_options options
        set_filter_to options
        search_paginate City.search_and_sort(options).with_country_columns, options
      else
        City.accessible_by(current_ability).order("common ASC, name ASC").with_country_columns.paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def show
    @city = City.where(:id => params[:id]).first
  end

  def new
  end

  def create
    if @city.save_with_dropdown_lists(current_company, params[:city])
      redirect_to cities_path, :notice => t('cities.messages.created')
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @city.update_with_dropdown_lists(current_company, params[:city])
      redirect_to cities_path, :notice => t('cities.messages.updated')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @city.destroy
    redirect_to cities_path, :notice => t('cities.messages.destroyed')
  end

  private
    def set_filter_to(options)
      options[:with] ||= {}
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