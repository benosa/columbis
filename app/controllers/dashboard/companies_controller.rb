# -*- encoding : utf-8 -*-
class Dashboard::CompaniesController < ApplicationController
  include CountriesHelper

  skip_before_filter :check_company_is_active

  load_and_authorize_resource
  skip_authorize_resource only: :edit

  rescue_from CanCan::AccessDenied do |exception|
    if [:update, :destroy].include?(exception.action) && can?(:read, exception.subject)
      message = t("companies.messages.company_cant_be_#{exception.action == :update ? 'updated' : 'destroyed'}")
      redirect_to dashboard_edit_company_path, :alert => message
    else
      redirect_to root_path, :alert => exception.message
    end
  end

  def new
    @company.subdomain = current_user.subdomain
    build_company_edition_prerequisites
  end

  def create
    @company = Company.new(params[:company])
    if @company.save
      current_user.update_attribute(:company_id, @company.id)
      current_user.update_attribute(:office_id, @company.offices.first.id) unless @company.offices.empty?
      current_user.update_attribute(:subdomain, @company.subdomain) if @company.previous_changes['subdomain'] != nil
      @company.address.update_attribute(:company_id, @company.id) if @company.address.present?
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_created_company')
    else
      build_company_edition_prerequisites
      render :action => "new"
    end
  end

  def edit
    @company = current_company unless @company
    authorize! :read, @company
    build_company_edition_prerequisites
  end

  def update
    @company = current_company unless @company
    if @company.update_attributes(params[:company])
      current_user.update_attribute(:office_id, @company.offices.first.id) if current_user.office.nil? and !@company.offices.empty?
      if @company.previous_changes['subdomain'] != nil
        @boss = User.where(company_id: @company.id, role: :boss).first
        @boss.update_attribute(:subdomain, @company.subdomain) if @boss
      end
      @company.address.update_attribute(:company_id, @company.id) if @company.address.present?
      redirect_to dashboard_edit_company_path, :notice => t('companies.messages.successfully_updated_company')
    else
      build_company_edition_prerequisites
      render :action => "edit"
    end
  end

  private
    def build_empty_associations
      @company.offices.build if @company.offices.empty?
      @company.build_address unless @company.address.present?
    end

    # stub for current_company and current_office
    def stub_currents
      current_user.company = @company
      current_user.office = @company.offices.first || @company.offices.build
    end

    def build_company_edition_prerequisites
      build_empty_associations
      stub_currents
    end
end
