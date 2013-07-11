# -*- encoding : utf-8 -*-
class Dashboard::CompaniesController < ApplicationController
  load_and_authorize_resource
  include CountriesHelper

  def new
    build_company_edition_prerequisites
  end

  def create
    @company = Company.new(params[:company])
    if @company.save
      current_user.update_attribute(:company_id, @company.id)
      current_user.update_attribute(:office_id, @company.offices.first.id) unless @company.offices.empty?
      @company.address.update_attribute(:company_id, @company.id) if @company.address.present?
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_created_company')
    else
      build_company_edition_prerequisites
      render :action => "new"
    end
  end

  def edit
    @company = current_company unless @company
    build_company_edition_prerequisites
  end

  def update
    if @company.update_attributes(params[:company])
      current_user.update_attribute(:office_id, @company.offices.first.id) if current_user.office.nil? and !@company.offices.empty?
      @company.address.update_attribute(:company_id, @company.id) if @company.address.present?
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_updated_company')
    else
      build_company_edition_prerequisites
      render :action => "edit"
    end
  end

  def printers
    edit
    @company.printers.build
  end

  def update_printers
    if @company.update_attributes(params[:company])
      redirect_to printers_dashboard_company_path(current_company), :notice => t('companies.messages.successfully_updated_company')
    else
      build_company_edition_prerequisites
      render :action => "printers"
    end
  end

  private

    def build_empty_associations
      @company.offices.build(name: t('offices.default_name')) if @company.offices.empty?
      @company.build_address unless @company.address.present?
    end

    # stub for current_company and current_office
    def stub_currents
      current_user.company = @company
      current_user.office = @company.offices.first || @company.offices.build
    end

    def build_company_edition_prerequisites
      ActiveRecord::Associations::Preloader.new(@company, :printers => :country).run # preload printers association
      build_empty_associations
      stub_currents
    end
end
