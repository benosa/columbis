class Dashboard::DataTransferController < ApplicationController

  def index
    @import_list = ImportInfo.where(company_id: current_company.id).all
    @import_info = ImportInfo.new
    render :index
  end

  def export
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
    @totals = Claim.accessible_by(current_ability).includes(inluded_tables)

    @tourists = Tourist.accessible_by(current_ability).includes([:address, :user])

    @clients = Tourist.accessible_by(current_ability).includes(:address).potentials

    @managers = User.where(:company_id => current_company.id)

    @operators = Operator.by_company_or_common(current_company).includes(:address)

    @tourists_payments = Payment.where(:company_id => current_company.id, :payer_type => 'Tourist').order('date_in desc')

    @operator_payments = Payment.where(:company_id => current_company.id, :recipient_type => 'Operator').order('date_in desc')

    respond_to do |format|
      format.xls { render "claims" }
    end
  end

  def import
    @import_info = ImportInfo.create
    @import_info.company = current_company
    @import_info.filename = params[:import_info][:filename]
    @import_info.save
    @import_info.perform
    render :index
  end

end
