class ClaimsController < ApplicationController
  def index
    @claims = Claim.all
  end

  def show
    @claim = Claim.find(params[:id])
  end

  def new
    @claim = Claim.new
  end

  def create
    @claim = Claim.new(params[:claim])
    if @claim.save
      redirect_to @claim, :notice => "Successfully created claim."
    else
      render :action => 'new'
    end
  end

  def edit
    @claim = Claim.find(params[:id])
  end

  def update
    @claim = Claim.find(params[:id])
    if @claim.update_attributes(params[:claim])
      redirect_to @claim, :notice  => "Successfully updated claim."
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
