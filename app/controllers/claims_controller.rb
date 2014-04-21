# -*- encoding : utf-8 -*-
class ClaimsController < ApplicationController
  include ClaimsHelper
  ADDITIONAL_ACTIONS = [:totals, :update_bonus].freeze

  # Override loading resource by cancan
  before_filter :set_claim, :only => [:new, :create, :edit, :update, :update_bonus, :lock, :unlock, :printer]

  load_and_authorize_resource :except => ADDITIONAL_ACTIONS

  before_filter :set_commit_type,     :only => [:create, :update]
  before_filter :set_last_search,     :only => :index
  before_filter :permit_actions,      :only => ADDITIONAL_ACTIONS

  cache_sweeper :claim_sweeper, :only => [:create, :update, :destroy]

  def index
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
    if search_or_sort? # Last search was restored from session
      # remover any sql order by reorder(nil), because there are might be composed columns
      @claims_collection = search_paginate(Claim.search_and_sort(search_options).includes(inluded_tables) ).reorder(nil)
      @claims = Claim.sort_by_search_results(@claims_collection)
    else
      page_options = { :page => params[:page], :per_page => per_page }
      default_order = "claims.#{Claim::DEFAULT_SORT[:col]} #{Claim::DEFAULT_SORT[:dir]}, claims.id DESC"
      scoped = Claim.accessible_by(current_ability).order(default_order).includes(inluded_tables)
      if is_manager? # manager can see only his claims
        scoped = scoped.where('claims.user_id = :manager OR claims.assistant_id = :manager', manager: current_user.id)
      end
      if is_admin? && !params[:company_id]
        scoped = scoped.where('claims.company_id != ?', demo_company.id)
      end
      @claims_collection = scoped.paginate(page_options)
      @claims = @claims_collection.all
    end
    set_list_type
    @totals = get_totals(@claims) if params[:list_type] == 'accountant_list'
    limit_collection_total_entries @claims_collection
    if request.xhr?
      if current_company.short_claim_list
        render :partial => 'list_new'
      else
        render :partial => 'list'
      end
    end

  end

  def scroll
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
    # remover any sql order by reorder(nil), because there are might be composed columns
    @claims_collection = search_paginate(Claim.search_and_sort(search_options).includes(inluded_tables)).reorder(nil)
    @claims = Claim.sort_by_search_results(@claims_collection)
    set_list_type
    @totals = get_totals(@claims) if params[:list_type] == 'accountant_list'
    limit_collection_total_entries @claims_collection
    render 'scroll', :layout => false
  end

  def totals
    period = if params[:year].present? and params[:year] != 'all'
      Date.new(params[:year].to_i)..Date.new(params[:year].to_i, 12, 31)
    else
      :all
    end
    @totals = claim_totals(period, params)
    render :partial => 'totals'
  end

  def new
    @claim.fill_new
    check_flights
  end

  def create
    @claim.assign_reflections_and_save(params[:claim])

    unless @claim.errors.any?
      respond_to do |format|
        format.html {
          redirect_path = @commit_type == :save_and_close ? claims_url : edit_claim_url(@claim)
          redirect_to redirect_path, :notice => t('claims.messages.successfully_created_claim')
        }
        format.js {
          render :partial => 'claim_create'
        }
      end
    else
      @claim.applicant ||= Tourist.new #Tourist.new(params[:claim][:applicant_attributes])
      check_payments
      check_flights
      render :action => 'new'
    end
  end

  def edit
    @claim.applicant ||= Tourist.new
    check_payments
    check_flights
  end

  def show
    @claim.applicant ||= Tourist.new
    check_payments
    check_flights
    render :action => 'edit'
  end

  def update
    @claim.assign_reflections_and_save(params[:claim])

    unless @claim.errors.any?
      redirect_path = @commit_type == :save_and_close ? claims_url : edit_claim_url(@claim)
      redirect_to redirect_path, :notice => t('claims.messages.successfully_updated_claim')
    else
      # @claim.applicant ||=
      #   (params[:claim][:applicant][:id].empty? ? Tourist.new(params[:claim][:applicant]) : Tourist.find(params[:claim][:applicant][:id]))
      check_payments
      check_flights
      render :action => 'edit'
    end
  end

  def update_bonus
    authorize! :update, @claim
    @claim.update_bonus(params[:claim][:bonus_percent])
    @claim.save
    # respond_with_bip(@claim)
    render :json => {
      :bonus => @claim.bonus.to_money,
      :bonus_percent => @claim.bonus_percent.to_percent
    }
  end

  def lock
    # authorize! :update, @claim
    unless @claim.locked?
      @claim.lock(current_user)
      render :json => {
        :message => I18n.t('claims.messages.locked')
      }
    else
      render :json => {
        :locked => @claim.locked_by
      }
    end
  end

  def unlock
    # authorize! :update, @claim
    if @claim.edited?
      unless @claim.locked?
        @claim.unlock
      else
        render :json => { :wrong_user => 1 }
        return
      end
    end
    render :json => { :unlocked => 1 }
  end

  def destroy
    @claim.destroy
    redirect_to claims_url, :notice =>  t('claims.messages.successfully_destroyed_claim')
  end

  private

    def set_list_type
      params[:list_type] ||= 'manager_list' if demo_company?
      if can?(:switch_view, current_user)
        params[:list_type] ||= 'accountant_list'
      else
        params[:list_type] = 'manager_list'
      end
    end

    def set_claim
      @claim = params[:id].present? ? Claim.find(params[:id]) : Claim.new
      @claim.company ||= current_company
      @claim.current_editor ||= current_user
      if params[:claim]
        @claim[:tour_price_currency] = CurrencyCourse::PRIMARY_CURRENCY
        @claim[:operator_price_currency] = CurrencyCourse::PRIMARY_CURRENCY
        if (is_admin? or is_boss?) && (params[:claim][:user_id] && params[:claim][:office_id])
          @claim.user_id = params[:claim][:user_id]
          @claim.office_id = params[:claim][:office_id]
        else
          @claim.user ||= current_user
          @claim.office ||= current_office
        end
        @claim.assign_attributes(params[:claim])
      else
        @claim.user ||= current_user
        @claim.office ||= current_office
      end
    end

    def check_payments
      @claim.payments_in.build(:currency => CurrencyCourse::PRIMARY_CURRENCY) if @claim.payments_in.empty?
      if !@claim.new_record? && @claim.payments_out.empty?
        @claim.payments_out.build(:currency => @claim.operator_price_currency || CurrencyCourse::PRIMARY_CURRENCY, :course => '')
      end
    end

    def check_flights
      new_records = 2 - @claim.flights.length
      new_records.times {|i| @claim.flights.build} if new_records > 0
    end

    def set_commit_type
      @commit_type = :save_and_close if params[:save_and_close]
      @commit_type = params[:commit] == I18n.t('save_and_close') ? :save_and_close : :save unless @commit_type
      @commit_type
    end

    def search_options
      return @search_options if @search_options
      opts = search_and_sort_options(defaults: {
        :order => Claim::DEFAULT_SORT[:col],
        :sort_mode => Claim::DEFAULT_SORT[:dir]
      })
      opts[:index] = mistral_claim_list? ? 'mistral_claim_index' : 'short_claim_index'
      opts[:with] = current_ability.attributes_for(:read, Claim) # opts[:with] = { :company_id => current_company.id }
      opts[:with][:active] = true if params[:only_active] == '1'

      if is_admin?
        if params[:company_id]
          opts[:with][:company_id] = params[:company_id]
        else
          demo_id = demo_company.id
          opts[:sphinx_select] = "*, IF(company_id = #{demo_id}, 0, 1) AS not_demo"
          opts[:with]['not_demo'] = 1
        end
      end

      if is_admin? or is_boss? or is_supervisor? or is_accountant?
        unless params[:user_id].blank?
          manager = params[:user_id].to_i
          opts[:sphinx_select] = "*, IF(user_id = #{manager} OR assistant_id = #{manager}, 1, 0) AS manager"
          opts[:with]['manager'] = 1
        end
        opts[:with][:office_id] = params[:office_id] unless params[:office_id].blank?
      else
        params[:only_my] = '1' # TODO: temporary for Mistral, need change abilities
        opts[:with][:office_id] = current_office.id
        if params[:only_my] == '1'
          manager = current_user.id
          opts[:sphinx_select] = "*, IF(user_id = #{manager} OR assistant_id = #{manager}, 1, 0) AS manager"
          opts[:with]['manager'] = 1
        end
      end

      if mistral_claim_list?
        opts[:order] = "#{opts[:order]} #{opts[:sort_mode]}, id #{opts[:sort_mode]}"
      else
        opts[:sphinx_select] = "#{opts[:sphinx_select] || '*'}, IF(check_date <= NOW() AND active = 1, 1, 0) AS check_date_alert"
        opts[:order] = "check_date_alert DESC, #{opts[:order]} #{opts[:sort_mode]}, id #{opts[:sort_mode]}"
      end

      opts[:sort_mode] = :extended
      @search_options = opts.delete_if{ |key, value| value.blank? }
    end

    def exluded_search_params
      [:controller, :action, :accountant_list]
    end

    def search_params
      return @search_params if @search_params
      @search_params = {}
      unless params[:sort] == Claim::DEFAULT_SORT[:col] && params[:direction] == Claim::DEFAULT_SORT[:dir]
        @search_params[:sort] = params[:sort] if params[:sort]
        @search_params[:direction] = params[:direction] if params[:direction]
      end
      exluded_params = exluded_search_params + [:sort, :direction]
      params.each do |k, v|
        @search_params[k] = v unless exluded_params.include?(k.to_sym) || v.blank?
      end
      @search_params
    end

    # override application helper
    def search_or_sort?
      params[:sort].present? or !params.select{ |k, v| !exluded_search_params.include?(k.to_sym) }.empty?
    end

    def set_last_search
      session_key = :claims_last_search
      if params[:unset_filters]
        session[session_key] = nil
      elsif search_or_sort?
        session[session_key] = !search_params.empty? ? search_params : nil;
      elsif session[session_key].present?
        params.reverse_merge!(session[session_key])
      end
    end

    def claim_totals(period, filters = {})
      conditions = ["company_id = :company_id", "excluded_from_profit = :excluded_from_profit"]
      binds = { :company_id => current_company, :excluded_from_profit => false }
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
               sum(profit_acc) as profit_acc,
               sum(primary_currency_price) as primary_currency_price,
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
      totals.delete_if{ |t| t.month.to_i == Time.zone.now.month }
    end

    def get_totals(claims)
      # show totals only if list is sorted by reservation_date
      if (is_admin? or is_boss?) and sort_col == :reservation_date and !claims.empty?
         # Get beginning of month of min date and end of month of max date from particular claims
        period = if sort_dir == :desc
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
      when action == :totals
        is_admin? or is_boss?
      when action == :update_bonus
        is_admin? or is_boss? or is_accountant?
      end
      redirect_to :status => 404 unless allowed
    end

end
