class Dashboard::DataTransferController < ApplicationController

  def export
    inluded_tables = [:user, :office, :operator, :country, :city, :applicant, :dependents, :assistant]
    @totals = Claim.accessible_by(current_ability).includes(inluded_tables)

    @tourists = Tourist.accessible_by(current_ability).includes([:address, :user])

    @clients = Tourist.accessible_by(current_ability).includes(:address).potentials

    @managers = User.where(:company_id => current_company.id)

    respond_to do |format|
      format.xls { render "claims" }
    end
  end

end
