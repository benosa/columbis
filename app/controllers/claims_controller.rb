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

  def index
    @claims = Claim.all
  end

  def show
    @claim = Claim.find(params[:id])
  end

  def new
    @claim = Claim.new
    @claim.applicant ||= Tourist.new
  end

  def create
    @claim = Claim.new(params[:claim])
    @claim.assign_applicant(params[:claim][:applicant])
    raise @claim.errors.inspect
    if @claim.save
      redirect_to claims_url, :notice => t('.successfully_created_claim.')
    else
      render :action => 'new'
    end
  end

  def edit
    @claim = Claim.find(params[:id])
    @claim.applicant ||= Tourist.new
  end

  def update
    @claim = Claim.find(params[:id])
    if @claim.update_attributes(params[:claim])
      redirect_to claims_url, :notice  => "Successfully updated claim."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @claim = Claim.find(params[:id])
    @claim.destroy
    redirect_to claims_url, :notice => "Successfully destroyed claim."
  end
end
