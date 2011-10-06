class CompaniesController < ApplicationController
  def new
    @company = Company.new
    @company.build_address
  end

  def create
    @company = Company.new(params[:company])

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, :notice => 'Company was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @company = Company.find(params[:id])
    if !@company.address.present?
      @company.build_address
    end
  end

  def update
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(params[:company])
        format.html { redirect_to @company, :notice => 'Company was successfully updated.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def index
    @companies = Company.find(:all)
  end

  def show
    @company = Company.find(params[:id])
  end

  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_url }
    end
  end
end
