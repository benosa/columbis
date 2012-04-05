class TouristsController < ApplicationController
  load_and_authorize_resource

  def index
    @tourists = Tourist.where(:company_id => current_company.id)
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

end
