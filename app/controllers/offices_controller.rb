class OfficesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :new

  def index
    @offices = Office.where(:company_id => current_user.company_id).accessible_by(current_ability)
  end

  def new
    @office = Office.new
  end

  def create
    @office = Office.new(params[:office])
    @office.company = current_user.company

    if @office.save
      current_user.update_attribute(:office_id, @office.id)
      redirect_to offices_url, :notice => "Successfully created office."
    else
      render :action => 'new'
    end
  end

  def edit
    @office = Office.find(params[:id])
  end

  def update
    @office = Office.find(params[:id])
    @office.company ||= current_user.company

    if @office.update_attributes(params[:office])
      redirect_to offices_url, :notice  => "Successfully updated office."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @office = Office.find(params[:id])
    if @office.destroy
      redirect_to offices_url, :notice => 'Successfully destroyed office.'
    else
      render :action => 'edit'
    end
  end
end
