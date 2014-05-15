# -*- encoding : utf-8 -*-
class TouristsController < ApplicationController
  include TouristsHelper
  load_and_authorize_resource

  before_filter :set_last_search, :only => :index

  def index
    @tourists =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Tourist))
        options[:with][:user_id] = params[:user_id].to_i if params[:user_id].present?
        checkout_order(options)
        scoped = Tourist.search_and_sort(options).includes(:address, (:user if show_potential_clients))
        scoped = scoped.potentials if show_potential_clients
        scoped = search_paginate(scoped, options)
      else
        scoped = Tourist.send(show_potential_clients ? :potentials : :clients)
        scoped = scoped.accessible_by(current_ability).includes(:address, (:user if show_potential_clients))
        scoped = scoped.reorder('created_at DESC') if show_potential_clients
        scoped.paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
    @tourist.potential = true if show_potential_clients
    check_address(@tourist)
  end

  def create
    @tourist.company = current_company
    @tourist.user = current_user
    set_images
    if @tourist.save
      redirect_to_tourists(@tourist.potential?, :created)
    else
      @tourist.user = nil
      check_address(@tourist)
      render :action => "new"
    end
  end

  def edit
    check_address(@tourist)
  end

  def update
    @tourist.company = current_company
    manager = @tourist.user
    @tourist.user = current_user unless manager
    set_images
    if @tourist.update_attributes(params[:tourist])
      redirect_to_tourists(@tourist.potential?, :updated)
    else
      @tourist.user = nil unless manager
      check_address(@tourist, params[:potential])
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    @tourist.destroy
    unless request.xhr?
      redirect_to_tourists(@tourist.potential?, :destroyed)
    else
      render :text => ''
    end
  end

  private

    def set_images
      @tourist.images.each do |img|
        img.company = current_company if img.file
      end
    end

    def check_offline
      if params[:offline] && params[:id] == '0'
        @tourist = Tourist.new
        @tourist.id = 0
      end
    end

    def checkout_order(options)
      options[:with].merge!(:potential => show_potential_clients)
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
      session_key = show_potential_clients ? :potential_tourists_last_search : :tourists_last_search
      if params[:unset_filters]
        session[session_key] = nil
      elsif search_or_sort?
        session[session_key] = !search_params.empty? ? search_params : nil;
      elsif session[session_key].present?
        params.reverse_merge!(session[session_key])
      end
    end

    def redirect_to_tourists(is_potential, message_key)
      message = t("tourists.messages.#{is_potential ? 'client_' : ''}#{message_key}")
      unless is_potential
        redirect_to tourists_path, :notice => message
      else
        redirect_to tourists_path(potential: 1), :notice => message
      end
    end

    def check_address(tourist, is_potential = nil)
      tourist.build_address unless tourist.address || (is_potential.nil? ? tourist.potential? : is_potential)
    end

end
