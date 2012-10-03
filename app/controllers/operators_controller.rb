class OperatorsController < ApplicationController
  load_and_authorize_resource

  def index
    @operators =
      if search_or_sort?
        # search_and_sort(Operator, {
        #   # Use company_id facet for operators instead of accessible_by(current_ability) of CanCan
        #   # To use with CanCan maybe useful this gem https://github.com/sylogix/can_sphinx
        #   :with => { :company_id => current_company.id }
        #   :include => :address,
        #   :per_page => per_page
        # })
        # Use company_id facet for operators instead of accessible_by(current_ability) of CanCan
        # To use with CanCan maybe useful this gem https://github.com/sylogix/can_sphinx
        options = search_and_sort_options(:with => { :company_id => current_company.id })
        search_paginate(Operator.search_and_sort(options).includes(:address), options)
      else
        Operator.accessible_by(current_ability).includes(:address).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def show
  end

  def new
    @operator.build_address
  end

  def create
    @operator.company = current_company
    @operator.address.company = current_company
    if @operator.save
      redirect_to @operator, :notice => "Successfully created operator."
    else
      render :action => 'new'
    end
  end

  def edit
    if !@operator.address.present?
      @operator.build_address
    end
  end

  def update
    @operator.company ||= current_company
    @operator.address.company ||= current_company if @operator.address.present?
    if @operator.update_attributes(params[:operator])
      redirect_to @operator, :notice  => "Successfully updated operator."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @operator.destroy
    redirect_to operators_url, :notice => "Successfully destroyed operator."
  end
end
