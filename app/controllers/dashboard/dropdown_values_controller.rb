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
  end

  def create
    @dropdown_value.company_id = current_company.id
    if @dropdown_value.save
      redirect_to dashboard_dropdown_values_url, :notice => t('dropdown_values.messages.successfully_created_dropdown_value')
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @dropdown_value.company_id ||= current_company.id
    if @dropdown_value.update_attributes(params[:dropdown_value])
      redirect_to dashboard_dropdown_values_url, :notice  => t('dropdown_values.messages.successfully_updated_dropdown_value')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @dropdown_value.destroy
    redirect_to dashboard_dropdown_values_url, :notice => t('dropdown_values.messages.successfully_destroyed_dropdown_value')
  end
end
