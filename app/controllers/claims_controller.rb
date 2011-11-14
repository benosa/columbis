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
    case params[:model]
      when 'airline'
        render :json => Airline.where(["name ILIKE '%' || ? || '%'", params[:term]]).map { |o| { :label => o.name, :value => o.name } }
    end
  end

  def index
    @claims = Claim.all
  end

  def show
    @claim = Claim.find(params[:id])
  end

  def new
    @claim = Claim.new
    @claim.applicant = Tourist.new
    @claim.payments_in << Payment.new
    @claim.payments_out << Payment.new
    @claim.set_new_num
  end

  def create
    @claim = Claim.new(params[:claim])
    @claim.assign_reflections_and_save(params[:claim])
    unless @claim.errors.any?
      redirect_to claims_url, :notice => t('.successfully_created_claim.')
    else
      @claim.applicant ||= Tourist.new(params[:claim][:applicant])
      @claim.payments_in << Payment.new if @claim.payments_in.empty?
      @claim.payments_out << Payment.new if @claim.payments_out.empty?
      render :action => 'new'
    end
  end

  def edit
    @claim = Claim.find(params[:id])
    @claim.applicant ||= Tourist.new
    @claim.payments_in << Payment.new if @claim.payments_in.empty?
    @claim.payments_out << Payment.new if @claim.payments_out.empty?
  end

  def update
    @claim = Claim.find(params[:id])
    @claim.assign_reflections_and_save(params[:claim])
    unless @claim.errors.any?
      if @claim.update_attributes(params[:claim])
        redirect_to claims_url, :notice  => "Successfully updated claim."
      else
        render :action => 'edit'
      end
    else
      @claim.applicant ||=
        (params[:claim][:applicant][:id].empty? ? Tourist.new(params[:claim][:applicant]) : Tourist.find(params[:claim][:applicant][:id]))
      render :action => 'edit'
    end
  end

  def destroy
    @claim = Claim.find(params[:id])
    @claim.destroy
    redirect_to claims_url, :notice => "Successfully destroyed claim."
  end
end
