class TouristsController < ApplicationController
  load_and_authorize_resource  

  def index
  end

  def new
  end

  def create
    @tourist.company = current_company
    if @tourist.save
      redirect_to @tourist, :notice => 'Tourist was successfully created.'
    else
      render :action => "new"
    end
  end

  def edit    
  end

  def update
    @tourist.company = current_company
    if @tourist.update_attributes(params[:tourist])
      redirect_to @tourist, :notice => 'Tourist was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def show    
  end

  def destroy
    @tourist.destroy
    redirect_to tourists_url
  end

  private

    def check_offline
      if params[:offline] && params[:id] == '0'
        @tourist = Tourist.new
        @tourist.id = 0
      end
    end

end
