class Dashboard::CompaniesController < ApplicationController
  load_and_authorize_resource

  def index
    @companies = Company.where(:id => current_user.company_id).accessible_by(current_ability)
  end

  def new
    @company = Company.new
    @company.build_address
    @company.build_city
  end

  def create
    @company = Company.new(params[:company])

    if @company.save
      current_user.update_attribute(:company_id, @company.id)
      redirect_to @company, :notice => 'Company was successfully created.'
    else
      render :action => "new"
    end
  end

  def edit
    @company = current_company unless @company

    @company.offices.build
    @company.printers.build
    if !@company.address.present?
      @company.build_address
    end
  end

  def update
    if @company.update_attributes(params[:company])
      redirect_to root_url, :notice => 'Company was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def show
    @company = Company.find(params[:id])
  end

  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    redirect_to companies_url
  end
end
