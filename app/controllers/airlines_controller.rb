class AirlinesController < ApplicationController
  def index
    @airlines = Airline.all
  end

  def show
    @airline = Airline.find(params[:id])
  end

  def new
    @airline = Airline.new
  end

  def create
    @airline = Airline.new(params[:airline])
    if @airline.save
      redirect_to airlines_url, :notice => "Successfully created airline."
    else
      render :action => 'new'
    end
  end

  def edit
    @airline = Airline.find(params[:id])
  end

  def update
    @airline = Airline.find(params[:id])
    if @airline.update_attributes(params[:airline])
      redirect_to airlines_url, :notice  => "Successfully updated airline."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @airline = Airline.find(params[:id])
    @airline.destroy
    redirect_to airlines_url, :notice => "Successfully destroyed airline."
  end
end
