class ClaimsController < ApplicationController
  load_and_authorize_resource
  autocomplete :tourist, :last_name, :full => true
  helper_method :sort_column, :sort_direction

  def autocomplete_tourist_last_name
    render :json => Tourist.where(["last_name ILIKE '%' || ? || '%'", params[:term]]).map { |tourist|
      {
        :label => tourist.last_name,
        :value => tourist.full_name,
        :id => tourist.id,
        :passport_series => tourist.passport_series,
        :passport_number => tourist.passport_number,
        :date_of_birth => tourist.date_of_birth,
        :passport_valid_until => tourist.passport_valid_until,
        :phone_number => tourist.phone_number,
        :address => tourist.address
      }
    }
  end

  def autocomplete_common
    render :json => DropdownValue.dd_for(params[:list]).map { |dd| { :label => dd.value, :value => dd.value } }
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
    @claims = Claim.search_and_sort(:filter => params[:filter], :column => sort_column,
      :direction => sort_direction).paginate(:page => params[:page], :per_page => 40)
    if can? :switch_view, current_user
      params[:list_type] ||= 'manager_list'
    else
      params[:list_type] = 'manager_list'
    end
    render :partial => params[:list_type]
  end

  def index
    params[:list_type] ||= 'manager_list'
    @claims = Claim.search_and_sort(:column => sort_column,
          :direction => sort_direction).paginate(:page => params[:page], :per_page => 40)
  end

  def show
    @claim = Claim.find(params[:id])
    if %w[contract memo].include? params[:print]
      if params[:print] == 'memo'
        if @claim.has_memo_partial?
          render :partial => @claim.memo_partial, :layout => false
        else
          redirect_to edit_claim_url(@claim.id), :alert => t('print_partial_not_found')
        end
      else
        render :partial => params[:print], :layout => false
      end

    end
  end

  def new
    @claim = Claim.new( :user_id => current_user.id)
    @claim.fill_new
  end

  def create
    @claim = Claim.new(params[:claim])
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
    @claim = Claim.find(params[:id])
    @claim.applicant ||= Tourist.new
    check_payments
  end

  def update
    @claim = Claim.find(params[:id])
    @claim.assign_reflections_and_save(params[:claim])
    unless @claim.errors.any?
      if @claim.update_attributes(params[:claim])
        redirect_to claims_url, :notice  => t('claims.messages.successfully_updated_claim')
      else
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
    @claim = Claim.find(params[:id])
    @claim.destroy
    redirect_to claims_url, :notice =>  t('claims.messages.successfully_destroyed_claim')
  end

  private

  def check_payments
    @claim.payments_in << Payment.new if @claim.payments_in.empty?
    @claim.payments_out << Payment.new if @claim.payments_out.empty?
  end

  def sort_column
    accesible_column_names = Claim.column_names + ['applicant.last_name', 'countries.name', 'operators.name', 'offices.name']
    accesible_column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end
end
