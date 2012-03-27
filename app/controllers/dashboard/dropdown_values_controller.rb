class Dashboard::DropdownValuesController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:list]
      @dropdown_values = DropdownValue.where(:list => params[:list], :company_id => current_user.company_id)
      render :partial => 'table'
    else
      @dropdown_values = DropdownValue.where(:company_id => current_user.company_id)
    end
  end

  def new
    @dropdown_value = DropdownValue.new
  end

  def create
    @dropdown_value = DropdownValue.new(params[:dropdown_value])
    if @dropdown_value.save
      redirect_to dropdown_values_url, :notice => "Successfully created dropdown_value."
    else
      render :action => 'new'
    end
  end

  def edit
    @dropdown_value = DropdownValue.find(params[:id])
  end

  def update
    @dropdown_value = DropdownValue.find(params[:id])
    if @dropdown_value.update_attributes(params[:dropdown_value])
      redirect_to dropdown_values_url, :notice  => "Successfully updated dropdown_value."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @dropdown_value = DropdownValue.find(params[:id])
    @dropdown_value.destroy
    redirect_to dropdown_values_url, :notice => "Successfully destroyed dropdown_value."
  end
end
