class ClaimsController < ApplicationController
  load_and_authorize_resource
  autocomplete :tourist, :last_name, :full => true
  helper_method :sort_column, :sort_direction

  before_filter :set_protected_attr, :only => [:create, :update]

  def autocomplete_tourist_last_name
    render :json => Tourist.where(["last_name ILIKE '%' || ? || '%'", params[:term]]).map { |tourist|
      {
        :label => tourist.last_name,
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

  def autocomplete_model_common
    if %w[airline operator country city resort].include?(params[:model])
      if params[:model] == 'resort'
        cls = City
      else
        cls = eval("#{params[:model].classify}")
      end
      render :json => cls.where(["name ILIKE '%' || ? || '%'", params[:term]]).map { |o| { :label => o.name, :value => o.name } }
    end
  end

  def search
    @claims = current_company.claims.search_and_sort(:filter => params[:filter], :column => sort_column,
      :direction => sort_direction).paginate(:page => params[:page], :per_page => 40)
    set_list_type
    render :partial => 'list'
  end

  def index
    params[:list_type] || set_list_type
    @claims = current_company.claims.search_and_sort(:column => sort_column,
          :direction => sort_direction).paginate(:page => params[:page], :per_page => 40)
  end

  def show
    if %w[contract memo].include? params[:print]
      case params[:print]
      when 'contract'
        render :text => @claim.print_contract, :layout => false
      when 'memo'
        render :text => @claim.print_memo, :layout => false
      end
    else
      redirect_to claims_url, :alert => "#{t('print_partial_not_found')} '#{params[:print]}'"
    end
  end

  def new
    @claim = Claim.new( :user_id => current_user.id)
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
    @claim.user ||= current_user
    @claim.company ||= current_company
    @claim.office ||= current_office
  end

  def check_payments
    @claim.payments_in << Payment.new(:currency => CurrencyCourse::PRIMARY_CURRENCY) if @claim.payments_in.empty?
    @claim.payments_out << Payment.new(:currency => @claim.operator_price_currency) if @claim.payments_out.empty?
  end

  def sort_column
    accesible_column_names = Claim.column_names + ['applicant.last_name', 'countries.name', 'operators.name', 'offices.name']
    accesible_column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end
end
