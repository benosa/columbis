# -*- encoding : utf-8 -*-
class TouristsController < ApplicationController
  load_and_authorize_resource

  def index
    @tourists =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Tourist))
        checkout_order(options)
        scoped = Tourist.search_and_sort(options).includes(:address)
        scoped = scoped.potential if params[:potential].present?
        scoped = search_paginate(scoped, options)
      else
        scoped = Tourist.send(!params[:potential] ? :clients : :potentials)
        scoped.accessible_by(current_ability).includes(:address).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
    @tourist.build_address
  end

  def create
    @tourist.company = current_company
    if @tourist.save
      redirect_to tourists_url, :notice => t('tourists.messages.created')
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    @tourist.company = current_company
    if @tourist.update_attributes(params[:tourist])
      redirect_to tourists_url, :notice => t('tourists.messages.updated')
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    @tourist.destroy
    redirect_to tourists_url, :notice => t('tourists.messages.destroyed')
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

end
