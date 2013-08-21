# -*- encoding : utf-8 -*-
class TouristsController < ApplicationController
  load_and_authorize_resource

  before_filter :set_last_search, :only => :index

  def index
    @tourists =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Tourist))
        options[:with][:user_id] = params[:user_id].to_i if params[:user_id].present?
        checkout_order(options)
        scoped = Tourist.search_and_sort(options).includes(:address, (:user if params[:potential]))
        scoped = scoped.potentials if params[:potential].present?
        scoped = search_paginate(scoped, options)
      else
        scoped = Tourist.send(params[:potential] ? :potentials : :clients)
        scoped.accessible_by(current_ability).includes(:address, (:user if params[:potential])).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
    @tourist.build_address
    @tourist.potential = true if params[:potential]
  end

  def create
    @tourist.company = current_company
    @tourist.user = current_user
    if @tourist.save
      redirect_to @tourist.potential ? tourists_path(potential: 1) : tourists_path, :notice => t('tourists.messages.created')
    else
      @tourist.user = nil
      render :action => "new"
    end
  end

  def edit
    @tourist.build_address unless @tourist.address
  end

  def update
    @tourist.company = current_company
    if @tourist.update_attributes(params[:tourist])
      redirect_to @tourist.potential ? tourists_path(potential: 1) : tourists_path, :notice => t('tourists.messages.updated')
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    @tourist.destroy
    unless request.xhr?
      redirect_to tourists_path, :notice => t('tourists.messages.destroyed')
    else
      render :text => ''
    end
  end

  private

    def check_offline
      if params[:offline] && params[:id] == '0'
        @tourist = Tourist.new
        @tourist.id = 0
      end
    end

    def checkout_order(options)
      options[:with].merge!(:potential => params[:potential].present?)
      if options[:order] == :full_name
        options[:sql_order] = %w[last_name first_name middle_name].map{|f| "#{f} #{options[:sort_mode]}"}.join(',')
      elsif options[:order] == :passport
        options[:sql_order] = %w[passport_series passport_number].map{|f| "#{f} #{options[:sort_mode]}"}.join(',')
      end
    end

    def search_params
      return @search_params if @search_params
      @search_params = {}
      exluded_params = [:controller, :action, :potential]
      params.each do |k, v|
        @search_params[k] = v unless exluded_params.include?(k.to_sym) || v.blank?
      end
      @search_params
    end

    def set_last_search
      session_key = params[:potential].present? ? :potential_tourists_last_search : :tourists_last_search
      if params[:unset_filters]
        session[session_key] = nil
      elsif search_or_sort?
        session[session_key] = !search_params.empty? ? search_params : nil;
      elsif session[session_key].present?
        params.reverse_merge!(session[session_key])
      end
    end

end
