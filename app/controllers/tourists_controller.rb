class TouristsController < ApplicationController
  load_and_authorize_resource

  def index
    @tourists =
      if search_or_sort?
        options = search_and_sort_options(:with => current_ability.attributes_for(:read, Tourist))
        if options[:order] == :full_name
          options[:sql_order] = %w[last_name first_name middle_name].map{|f| "#{f} #{options[:sort_mode]}"}.join(',')
        elsif options[:order] == :passport
          options[:sql_order] = %w[passport_series passport_number].map{|f| "#{f} #{options[:sort_mode]}"}.join(',')
        end
        search_paginate(Tourist.search_and_sort(options).includes(:address), options)
      else
        Tourist.accessible_by(current_ability).includes(:address).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def new
  end

  def create
    @tourist.company = current_company
    if @tourist.save
      redirect_to @tourist, :notice => 'Tourist was successfully created.'
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    @tourist.company = current_company
    if @tourist.update_attributes(params[:tourist])
      redirect_to @tourist, :notice => 'Tourist was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    @tourist.destroy
    redirect_to tourists_url
  end

  private

    def check_offline
      if params[:offline] && params[:id] == '0'
        @tourist = Tourist.new
        @tourist.id = 0
      end
    end

end
