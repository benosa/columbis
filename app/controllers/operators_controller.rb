# -*- encoding : utf-8 -*-
class OperatorsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:show, :create, :edit]
  skip_load_resource only: :create

  before_filter :set_last_search, :only => :index

  def index
    @operators =
      if search_or_sort?
        options = { with_current_abilities: true }
        options.merge!(order: "common asc, #{sort_col} #{sort_dir}", sort_mode: :extended)
        options = search_and_sort_options options
        availability_filter options
        search_paginate Operator.search_and_sort(options).includes(:address), options
      else
        Operator.accessible_by(current_ability).order("common ASC, name ASC").includes(:address).paginate(:page => params[:page], :per_page => per_page)
      end
    render :partial => 'list' if request.xhr?
  end

  def show
    edit
    render :action => 'edit'
  end

  def new
    @operator.build_address
  end

  def create
    params[:operator][:address_attributes].delete(:id) if params[:operator][:address_attributes].kind_of?(Hash)
    @operator = Operator.new(params[:operator])
    @operator.company = current_company
    authorize! :create, @operator
    if @operator.save
      if @operator.address.present? and @operator.address.company.nil?
        @operator.address.company = current_company
        @operator.address.save
      end
      redirect_path = params[:create_own] ? edit_operator_path(@operator) : operators_path
      redirect_to redirect_path, :notice => t('operators.messages.created')
    else
      render :action => 'new'
    end
  end

  def edit
    @operator.build_address unless @operator.address.present?
    authorize! :read, @operator
    unless @operator.common?
      # If it's a twin of common operator, check for updates
      @operator.check_and_load_common_operator!
      @common_operator = @operator.common_operator
      unless @operator.synced_with_common_operator?
        @sync_proposition = @common_operator && @operator.updated_at < @common_operator.updated_at
        @operator.sync_with_common_operator! if params[:sync]
      end
    else
      @create_own_condition = cannot?(:update, @operator) && can?(:create, Operator)
    end
  end

  def update
    @operator.company ||= current_company
    if @operator.update_attributes(params[:operator])
      if @operator.address.present? and @operator.address.company.nil?
        @operator.address.company = current_company
        @operator.address.save
      end
      redirect_to operators_path, :notice => t('operators.messages.updated')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @operator.destroy
    redirect_to operators_path, :notice => t('operators.messages.destroyed')
  end

  def refresh
    if OperatorJobs::UpdateCommonOperator.working? params[:id]
      redirect_to edit_operator_path, :alert => t('operators.messages.refreshing')
    else
      redirect_to edit_operator_path, :notice => t('operators.messages.refresh')
    end
  end

  private

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
      session_key = :operators_last_search
      if params[:unset_filters]
        session[session_key] = nil
      elsif search_or_sort?
        session[session_key] = !search_params.empty? ? search_params : nil;
      elsif session[session_key].present?
        params.reverse_merge!(session[session_key])
      end
    end

end
