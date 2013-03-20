# -*- encoding : utf-8 -*-
class ClaimsController < ApplicationController
  include ClaimsHelper
  ADDITIONAL_ACTIONS = [:autocomplete_tourist_last_name, :autocomplete_country, :autocomplete_resort, :totals, :update_bonus].freeze

  load_and_authorize_resource :except => ADDITIONAL_ACTIONS

  autocomplete :tourist, :last_name, :full => true

  before_filter :set_protected_attr,  :only => [:create, :update]
  before_filter :set_commit_type,     :only => [:create, :update]
  before_filter :set_last_search,     :only => :index
  before_filter :permit_actions,      :only => ADDITIONAL_ACTIONS

  cache_sweeper :claim_sweeper, :only => [:create, :update, :destroy]

  def autocomplete_tourist_last_name
    render :json => Tourist.accessible_by(current_ability).where(["last_name ILIKE '%' || ? || '%'", params[:term]]).limit(20).map { |tourist|
      {
        :label => tourist.full_name,
        :value => tourist.full_name,
        :id => tourist.id,
        :passport_series => tourist.passport_series,
        :passport_number => tourist.passport_number,
        :date_of_birth => tourist.date_of_birth.try(:strftime, '%d.%m.%Y'),
        :passport_valid_until => tourist.passport_valid_until.try(:strftime, '%d.%m.%Y'),
        :phone_number => tourist.phone_number,
        :address => tourist.address.try(:joint_address)
      }
    }
  end

  def autocomplete_country
    render :json => Country.where(["(common = ? OR company_id = ?) AND name ILIKE '%' || ? || '%'", true, current_company.id, params[:term]]).order('name ASC').limit(20).map { |c|
      { :id => c.id, :value => c.name }
    }
  end

  def autocomplete_resort
    country_id = params[:country_id].mb_chars
    country_id = unless country_id.to_i > 0 # country_id is a string - name of country
      country_name = params[:country_id].strip
      cond = ["(common = ? OR company_id = ?) AND name = ?", true, current_company.id, country_name]
      Country.where(cond).first.try(:id)
    end
    cond = ["country_id = ? AND (common = ? OR company_id = ?) AND name ILIKE '%' || ? || '%'", country_id, true, current_company.id, params[:term]]
    render :json => City.where(cond).order('name ASC').limit(20).map { |c|
      { :id => c.id, :value => c.name }
    }
  end

  def autocomplete_common
    render :json => current_company.dropdown_for(params[:list]).map { |dd| { :label => dd.value, :value => dd.value } }
  end

  def index
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
    if search_or_sort? # Last search was restored from session
      # remover any sql order by reorder(nil), because there are might be composed columns
      @claims_collection = search_paginate(Claim.search_and_sort(search_options).includes(inluded_tables)).reorder(nil)
      @claims = Claim.sort_by_search_results(@claims_collection)
    else
      page_options = { :page => params[:page], :per_page => per_page }
      default_order = "claims.#{Claim::DEFAULT_SORT[:col]} #{Claim::DEFAULT_SORT[:dir]}, claims.id DESC"
      @claims_collection = Claim.accessible_by(current_ability).order(default_order).includes(inluded_tables).paginate(page_options)
      @claims = @claims_collection.all
    end
    set_list_type
    #@totals = get_totals(@claims) if params[:list_type] == 'accountant_list'
    render :partial => 'list' if request.xhr?
  end

  def scroll
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
    # remover any sql order by reorder(nil), because there are might be composed columns
    @claims_collection = search_paginate(Claim.search_and_sort(search_options).includes(inluded_tables)).reorder(nil)
    @claims = Claim.sort_by_search_results(@claims_collection)
    set_list_type
    #@totals = get_totals(@claims) if params[:list_type] == 'accountant_list'
    render 'scroll', :layout => false
  end

  def totals
    period = if params[:year].present? and params[:year] != 'all'
      Date.new(params[:year].to_i)..Date.new(params[:year].to_i, 12, 31)
    else
      :all
    end
    #@totals = claim_totals(period, params)
    render :partial => 'totals'
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
      redirect_path = @commit_type == :save_and_close ? claims_url : edit_claim_url(@claim.id)
      redirect_to redirect_path, :notice => t('claims.messages.successfully_created_claim')
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

    updated = nil
    unless @claim.errors.any?
      updated = @claim.update_attributes(params[:claim])
      if updated and @commit_type == :save_and_close
        redirect_to claims_url, :notice  => t('claims.messages.successfully_updated_claim')
        return
      end
    end

    flash.now[:notice] = t('claims.messages.successfully_updated_claim') if updated
    @claim.applicant ||=
      (params[:claim][:applicant][:id].empty? ? Tourist.new(params[:claim][:applicant]) : Tourist.find(params[:claim][:applicant][:id]))
    check_payments
    render :action => 'edit'
  end

  def update_bonus
    @claim = Claim.find(params[:id])
    authorize! :update, @claim
    @claim.update_bonus(params[:claim][:bonus_percent])
    # respond_with_bip(@claim)
    render :json => {
      :bonus => @claim.bonus.to_money,
      :bonus_percent => @claim.bonus_percent.to_percent
    }
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

  def set_commit_type
    @commit_type = params[:commit] == I18n.t('save_and_close') ? :save_and_close : :save
  end

  def search_options
    return @search_options if @search_options
    opts = search_and_sort_options
    opts[:with] = current_ability.attributes_for(:read, Claim) # opts[:with] = { :company_id => current_company.id }
    opts[:with][:active] = true if params[:only_active] == '1'
    if is_admin? or is_boss? or is_supervisor? or is_accountant?
      unless params[:user_id].blank?
        manager = params[:user_id].to_i
        opts[:sphinx_select] = "*, IF(user_id = #{manager} OR assistant_id = #{manager}, 1, 0) AS manager"
        opts[:with]['manager'] = 1
      end
      opts[:with][:office_id] = params[:office_id] unless params[:office_id].blank?
    else
      opts[:with][:office_id] = current_office.id
      if params[:only_my] == '1'
        manager = current_user.id
        opts[:sphinx_select] = "*, IF(user_id = #{manager} OR assistant_id = #{manager}, 1, 0) AS manager"
        opts[:with]['manager'] = 1
      end
    end
    @search_options = opts.delete_if{ |key, value| value.blank? }
  end

  def exluded_search_params
    [:controller, :action, :accountant_list]
  end

  def search_params
    return @search_params if @search_params
    @search_params = {}
    unless params[:sort] == Claim::DEFAULT_SORT[:col] and params[:direction] == Claim::DEFAULT_SORT[:dir]
      @search_params[:sort] = params[:sort] if params[:sort]
      @search_params[:direction] = params[:direction] if params[:direction]
    end
    exluded_params = exluded_search_params + [:sort, :direction]
    params.each do |k, v|
      @search_params[k] = v if !exluded_params.include?(k.to_sym) and v.present?
    end
    @search_params
  end

  # override application helper
  def search_or_sort?
    params[:sort].present? or !params.select{ |k, v| !exluded_search_params.include?(k.to_sym) }.empty?
  end

  def set_last_search
    if params[:unset_filters]
      session[:last_search] = nil
    elsif search_or_sort?
      session[:last_search] = !search_params.empty? ? search_params : nil;
    elsif session[:last_search].present?
      params.reverse_merge!(session[:last_search])
    end
  end

  def claim_totals(period, filters = {})
    conditions = ["company_id = :company_id"]
    binds = { :company_id => current_company }
    if period != :all
      # Get totals of montsh by current filters
      conditions << "reservation_date >= :begin AND reservation_date <= :end"
      binds[:begin] = period.begin
      binds[:end] = period.end
    end
    if filters[:user_id].present?
      conditions << "user_id = :user_id"
      binds[:user_id] = filters[:user_id]
    end
    if filters[:office_id].present?
      conditions << "office_id = :office_id"
      binds[:office_id] = filters[:office_id]
    end
    where = !conditions.empty? ? "WHERE #{conditions.join(' AND ')}" : ''
    query = <<-QUERY
      SELECT sum(approved_tourist_advance) as approved_tourist_advance,
             sum(approved_operator_advance) as approved_operator_advance,
             sum(profit) as profit,
             avg(profit_in_percent) as profit_in_percent,
             sum(bonus) as bonus,
             max(reservation_date) as reservation_date,
             EXTRACT(MONTH FROM reservation_date) as month,
             EXTRACT(YEAR FROM reservation_date) as year
      FROM claims
      #{where}
      GROUP BY EXTRACT(YEAR FROM reservation_date), EXTRACT(MONTH FROM reservation_date)
      QUERY
    totals = Claim.find_by_sql([query, binds]).sort_by{ |t| -t.month.to_i }
    # Remove current month
    totals.delete_if{ |t| t.month.to_i == Time.now.month }
  end

  def get_totals(claims)
    # show totals only if list is sorted by reservation_date
    if (is_admin? or is_boss?) and sort_col == 'reservation_date' and !claims.empty?
       # Get beginning of month of min date and end of month of max date from particular claims
      period = if sort_direction == 'desc'
        claims.last.reservation_date.beginning_of_month..claims.first.reservation_date.end_of_month
      else
        claims.first.reservation_date.beginning_of_month..claims.last.reservation_date.end_of_month
      end
      claim_totals(period, params)
    else
      nil
    end
  end

  def permit_actions
    action = params[:action].to_sym
    allowed = case
    when [:autocomplete_tourist_last_name, :autocomplete_country, :autocomplete_resort].include?(action)
      user_signed_in?
    when action == :totals
      is_admin? or is_boss?
    when action == :update_bonus
      is_admin? or is_boss? or is_accountant?
    end
    redirect_to :status => 404 unless allowed
  end

end
