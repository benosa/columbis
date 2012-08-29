class Dashboard::CompaniesController < ApplicationController
  load_and_authorize_resource

  def new
    @company.offices.build
    @company.printers.build
    @company.build_address
  end

  def create
    @company = Company.new(params[:company])    
    if @company.save
      current_user.update_attribute(:company_id, @company.id)
      current_user.update_attribute(:office_id, @company.offices.first.id) unless @company.offices.empty?
      @company.address.update_attribute(:company_id, @company.id)
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_created_company')
    else
      render :action => "new"
    end
  end

  def edit
    @company = current_company unless @company
    build_empty_associations
  end

  def update    
    if @company.update_attributes(params[:company])
      current_user.update_attribute(:office_id, @company.offices.first.id) if current_user.office.nil? and !@company.offices.empty?
      @company.address.update_attribute(:company_id, @company.id)
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_updated_company')
    else
      build_empty_associations
      render :action => "edit"
    end
  end

  private

    def build_empty_associations
      @company.offices.build
      @company.printers.build
      if !@company.address.present?
        @company.build_address
      end
    end
end
