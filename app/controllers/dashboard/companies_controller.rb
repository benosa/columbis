# -*- encoding : utf-8 -*-
class Dashboard::CompaniesController < ApplicationController
  load_and_authorize_resource
  include CountriesHelper

  def new
    build_empty_associations
    build_select_options
    stub_currents
  end

  def create
    @company = Company.new(params[:company])
    if @company.save
      current_user.update_attribute(:company_id, @company.id)
      current_user.update_attribute(:office_id, @company.offices.first.id) unless @company.offices.empty?
      @company.address.update_attribute(:company_id, @company.id) if @company.address.present?
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_created_company')
    else
      render :action => "new"
    end
  end

  def edit
    @company = current_company unless @company
    build_empty_associations
    build_select_options
    stub_currents
  end

  def update
    if @company.update_attributes(params[:company])
      current_user.update_attribute(:office_id, @company.offices.first.id) if current_user.office.nil? and !@company.offices.empty?
      @company.address.update_attribute(:company_id, @company.id) if @company.address.present?
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_updated_company')
    else
      build_empty_associations
      render :action => "edit"
    end
  end

  private

    def build_empty_associations
      @company.offices.build(name: t('offices.default_name')) if @company.offices.empty?
      @company.printers.build
      @company.build_address unless @company.address.present?
    end

    def build_select_options
      @countries_options = Country.select([:id, :name]).order(:id).all.map{ |o| [o.name, o.id] } # id = 1 - Russia
      @regions_options   = regions_for_select(@countries_options.first[1])
      @cities_options    = !@regions_options.empty? ? cities_for_select(@regions_options.first[1]) : []
    end

    # stub for current_company and current_office
    def stub_currents
      current_user.company = @company
      current_user.office = @company.offices.first || @company.offices.build
    end
end
