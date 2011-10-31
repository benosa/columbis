class TouristClaimsController < ApplicationController
  def index
    @tourist_claims = TouristClaim.all
  end

  def show
    @tourist_claim = TouristClaim.find(params[:id])
  end

  def new
    @tourist_claim = TouristClaim.new
  end

  def create
    @tourist_claim = TouristClaim.new(params[:tourist_claim])
    if @tourist_claim.save
      redirect_to @tourist_claim, :notice => "Successfully created tourist claim."
    else
      render :action => 'new'
    end
  end

  def edit
    @tourist_claim = TouristClaim.find(params[:id])
  end

  def update
    @tourist_claim = TouristClaim.find(params[:id])
    if @tourist_claim.update_attributes(params[:tourist_claim])
      redirect_to @tourist_claim, :notice  => "Successfully updated tourist claim."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @tourist_claim = TouristClaim.find(params[:id])
    @tourist_claim.destroy
    redirect_to tourist_claims_url, :notice => "Successfully destroyed tourist claim."
  end
end
