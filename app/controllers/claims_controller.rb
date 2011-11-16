class ClaimsController < ApplicationController
  load_and_authorize_resource
  autocomplete :tourist, :last_name, :full => true

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
    if %w[airline operator country city].include?(params[:model])
      cls = eval("#{params[:model].classify}")
      render :json => cls.where(["name ILIKE '%' || ? || '%'", params[:term]]).map { |o| { :label => o.name, :value => o.name } }
    end
  end

  def autocomplete_city
    country_filter = params[:country].to_i > 0 ? ('AND country_id = ' + params[:country]) : ''
    render :json => City.where(["name ILIKE '%' || ? || '%'" << country_filter,
                    params[:term]]).map { |o| { :label => o.name, :value => o.name } }
  end

  def index
    @claims = Claim.all
  end

  def show
    @claim = Claim.find(params[:id])
  end

  def new
    @claim = Claim.new( :user_id => current_user.id)
    @claim.fill
  end

  def create
    @claim = Claim.new(params[:claim])
    @claim.assign_reflections_and_save(params[:claim])
    unless @claim.errors.any?
      redirect_to claims_url, :notice => t('.successfully_created_claim.')
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
        redirect_to claims_url, :notice  => t('.successfully_updated_claim.')
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
    redirect_to claims_url, :notice =>  t('.successfully_destroyed_claim.')
  end

  private

  def check_payments
    @claim.payments_in << Payment.new if @claim.payments_in.empty?
    @claim.payments_out << Payment.new if @claim.payments_out.empty?
  end
end
