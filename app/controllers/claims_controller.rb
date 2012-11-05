# -*- encoding : utf-8 -*-
class ClaimsController < ApplicationController
  include ClaimsHelper

  load_and_authorize_resource

  autocomplete :tourist, :last_name, :full => true

  before_filter :set_protected_attr, :only => [:create, :update]

  def autocomplete_tourist_last_name
    render :json => Tourist.accessible_by(current_ability).where(["last_name ILIKE '%' || ? || '%'", params[:term]]).map { |tourist|
      {
        :label => tourist.full_name,
        :value => tourist.full_name,
        :id => tourist.id,
        :passport_series => tourist.passport_series,
        :passport_number => tourist.passport_number,
        :date_of_birth => tourist.date_of_birth.try(:strftime, '%d.%m.%Y'),
        :passport_valid_until => tourist.passport_valid_until.try(:strftime, '%d.%m.%Y'),
        :phone_number => tourist.phone_number,
        :address => tourist.address
      }
    }
  end

  def autocomplete_common
    render :json => current_company.dropdown_for(params[:list]).map { |dd| { :label => dd.value, :value => dd.value } }
  end

  def search
    opts = { :filter => params[:filter], :column => sort_column, :direction => sort_direction }
    if is_admin? or is_boss? or is_supervisor?
      opts[:user_id] = params[:user_id] unless params[:user_id].blank?
      opts[:office_id] = params[:office_id] unless params[:office_id].blank?
      @claims = Claim.accessible_by(current_ability).search_and_sort(opts).paginate(:page => params[:page], :per_page => per_page).offset(0)
    else
      opts[:user_id] = current_user.id if params[:only_my] == '1'
      @claims = Claim.accessible_by(current_ability).search_and_sort(opts).paginate(:page => params[:page], :per_page => per_page).offset(0)
    end
    set_list_type
    render :partial => 'list'
  end

  def index
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents]
    if search_or_sort?
      options = search_and_sort_options(
        :with => current_ability.attributes_for(:read, Claim),
        :defaults => { :order => :id, :sort_mode => :desc },
        :sql_order => false
      )
      set_filters(options)
      @claims_collection = search_paginate(Claim.search_and_sort(options).includes(inluded_tables), options)
      @claims = Claim.sort_by_search_results(@claims_collection)
    else
      @claims_collection = Claim.accessible_by(current_ability).includes(inluded_tables).paginate(:page => params[:page], :per_page => per_page)
      @claims = @claims_collection.all
    end
    set_list_type
    render :partial => 'list' if request.xhr?
  end

  def show
    if %w[contract memo permit warranty act].include? params[:print]
      case params[:print]
      when 'contract'
        render :text => @claim.print_contract, :layout => false
      when 'memo'
        render :text => @claim.print_memo, :layout => false
      when 'permit'
        render :text => @claim.print_permit, :layout => false
      when 'warranty'
        render :text => @claim.print_warranty, :layout => false
      when 'act'
        render :text => @claim.print_act, :layout => false
      end
    else
      redirect_to claims_url, :alert => "#{t('print_partial_not_found')} '#{params[:print]}'"
    end
  end

  def new
    @claim.company ||= current_company
    @claim.user ||= current_user
    @claim.office ||= current_office

    @claim.fill_new
  end

  def create
    @claim.assign_reflections_and_save(params[:claim])
    unless @claim.errors.any?
      redirect_to edit_claim_url(@claim.id), :notice => t('claims.messages.successfully_created_claim')
    else
      @claim.applicant ||= Tourist.new(params[:claim][:applicant])
      check_payments
      render :action => 'new'
    end
  end

  def edit
    @claim.applicant ||= Tourist.new
    check_payments
  end

  def update
    @claim.assign_reflections_and_save(params[:claim])

    unless @claim.errors.any?
      if @claim.update_attributes(params[:claim])
        redirect_to claims_url, :notice  => t('claims.messages.successfully_updated_claim')
      else
        @claim.applicant ||=
          (params[:claim][:applicant][:id].empty? ? Tourist.new(params[:claim][:applicant]) : Tourist.find(params[:claim][:applicant][:id]))
        check_payments
        render :action => 'edit'
      end
    else
      @claim.applicant ||=
        (params[:claim][:applicant][:id].empty? ? Tourist.new(params[:claim][:applicant]) : Tourist.find(params[:claim][:applicant][:id]))
      check_payments
      render :action => 'edit'
    end
  end

  def destroy
    @claim.destroy
    redirect_to claims_url, :notice =>  t('claims.messages.successfully_destroyed_claim')
  end

  private

    def set_list_type
      if can? :switch_view, current_user
        params[:list_type] ||= 'accountant_list'
      else
        params[:list_type] = 'manager_list'
      end
    end

    def set_protected_attr
      @claim.company ||= current_company

      if is_admin? or is_boss?
        @claim.user_id = params[:claim][:user_id]
        @claim.office_id = params[:claim][:office_id]
      else
        @claim.user ||= current_user
        @claim.office ||= current_office
      end
    end

    def check_payments
      @claim.payments_in << Payment.new(:currency => CurrencyCourse::PRIMARY_CURRENCY) if @claim.payments_in.empty?
      @claim.payments_out << Payment.new(:currency => CurrencyCourse::PRIMARY_CURRENCY) if @claim.payments_out.empty?
    end

    def set_filters(options)
      filter = {}
      filter[:user_id] = params[:user_id] if params[:user_id].present?
      filter[:office_id] = params[:office_id] if params[:office_id].present?
      options[:with].merge!(filter) unless filter.empty?
    end

end
